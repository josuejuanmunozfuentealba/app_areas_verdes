// API Serverless para envío de resumen diario automático en Vercel
// Se ejecuta a las 17:00 hrs Chile (UTC-4) vía Vercel Cron
// Consulta Supabase y envía reporte a Felipe Lagos Bastias

const nodemailer = require('nodemailer');

module.exports = async (req, res) => {
  // Configurar CORS
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  );

  // Manejar preflight OPTIONS
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    // Obtener fecha actual en Chile (UTC-4)
    const now = new Date();
    const chileDate = new Date(now.getTime() - (4 * 60 * 60 * 1000));
    const fechaHoy = chileDate.toISOString().split('T')[0]; // YYYY-MM-DD
    const fechaLegible = chileDate.toLocaleDateString('es-CL', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    });

    // Conectar a Supabase
    const supabaseUrl = process.env.SUPABASE_URL;
    const supabaseKey = process.env.SUPABASE_ANON_KEY;

    if (!supabaseUrl || !supabaseKey) {
      throw new Error('Faltan credenciales de Supabase');
    }

    // Consultar inspecciones técnicas del día
    const inspeccionesRes = await fetch(
      `${supabaseUrl}/rest/v1/inspecciones_tecnicas?fecha_hora_registro=gte.${fechaHoy}T00:00:00&fecha_hora_registro=lt.${fechaHoy}T23:59:59&order=fecha_hora_registro.desc`,
      {
        headers: {
          'apikey': supabaseKey,
          'Authorization': `Bearer ${supabaseKey}`
        }
      }
    );
    const inspecciones = inspeccionesRes.ok ? await inspeccionesRes.json() : [];

    // Consultar catastros del día
    const catastrosRes = await fetch(
      `${supabaseUrl}/rest/v1/catastros_inmuebles?fecha_hora_registro=gte.${fechaHoy}T00:00:00&fecha_hora_registro=lt.${fechaHoy}T23:59:59&order=fecha_hora_registro.desc`,
      {
        headers: {
          'apikey': supabaseKey,
          'Authorization': `Bearer ${supabaseKey}`
        }
      }
    );
    const catastros = catastrosRes.ok ? await catastrosRes.json() : [];

    // 🛑 REGLA: Si hay 0 registros hoy, cancelar envío
    if (inspecciones.length === 0 && catastros.length === 0) {
      return res.status(200).json({
        skipped: true,
        message: 'No hay registros para hoy. Envío cancelado.',
        date: fechaLegible,
        total: 0,
      });
    }

    // Generar resumen HTML
    const htmlBody = generarResumenHTML(inspecciones, catastros, fechaLegible);

    // Configurar transporte SMTP
    const transporter = nodemailer.createTransporter({
      host: process.env.SMTP_HOST || 'smtp.gmail.com',
      port: parseInt(process.env.SMTP_PORT || '587'),
      secure: process.env.SMTP_SECURE === 'true',
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
    });

    // Enviar correo a Felipe Lagos y equipo
    const info = await transporter.sendMail({
      from: `"Sistema Áreas Verdes Doñihue" <${process.env.SMTP_USER}>`,
      to: 'flagos@mdonihue.cl, aseoornatodonihue@gmail.com',
      subject: `📊 Resumen Diario de Áreas Verdes - ${fechaLegible}`,
      html: htmlBody,
      text: generarResumenTexto(inspecciones, catastros, fechaLegible),
    });

    return res.status(200).json({
      success: true,
      message: 'Resumen diario enviado exitosamente',
      messageId: info.messageId,
      date: fechaLegible,
      stats: {
        inspecciones: inspecciones.length,
        catastros: catastros.length,
      },
    });

  } catch (error) {
    console.error('Error al enviar resumen diario:', error);
    return res.status(500).json({
      success: false,
      error: 'Error al enviar el resumen diario',
      details: error.message,
    });
  }
};

// Función para generar HTML del resumen
function generarResumenHTML(inspecciones, catastros, fecha) {
  const totalInspecciones = inspecciones.length;
  const totalCatastros = catastros.length;

  // Agrupar inspecciones por estado
  const inspeccionesBuenas = inspecciones.filter(i => i.estado_general === 'Bueno').length;
  const inspeccionesRegulares = inspecciones.filter(i => i.estado_general === 'Regular').length;
  const inspeccionesMalas = inspecciones.filter(i => i.estado_general === 'Malo').length;

  // Agrupar catastros por estado
  const catastrosBuenos = catastros.filter(c => c.estado_general === 'Bueno').length;
  const catastrosRegulares = catastros.filter(c => c.estado_general === 'Regular').length;
  const catastrosMalos = catastros.filter(c => c.estado_general === 'Malo').length;

  return `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; background-color: #f5f5f5; margin: 0; padding: 20px; }
    .container { max-width: 800px; margin: 0 auto; background-color: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); overflow: hidden; }
    .header { background: linear-gradient(135deg, #1565C0 0%, #0D47A1 100%); color: white; padding: 30px; text-align: center; }
    .header h1 { margin: 0; font-size: 28px; font-weight: 600; }
    .header p { margin: 10px 0 0 0; font-size: 16px; opacity: 0.9; }
    .content { padding: 30px; }
    .stats-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin: 20px 0; }
    .stat-card { background: #f8f9fa; border-left: 4px solid #1565C0; padding: 20px; border-radius: 4px; }
    .stat-card h3 { margin: 0 0 10px 0; font-size: 14px; color: #666; text-transform: uppercase; letter-spacing: 0.5px; }
    .stat-card .number { font-size: 36px; font-weight: bold; color: #1565C0; }
    .section { margin: 30px 0; }
    .section-title { font-size: 20px; font-weight: 600; color: #1565C0; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 2px solid #e0e0e0; }
    .item { background: #f8f9fa; padding: 15px; margin-bottom: 10px; border-radius: 4px; border-left: 3px solid #1565C0; }
    .item-title { font-weight: 600; color: #333; margin-bottom: 5px; }
    .item-details { font-size: 14px; color: #666; }
    .badge { display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; margin-left: 8px; }
    .badge-bueno { background-color: #C8E6C9; color: #2E7D32; }
    .badge-regular { background-color: #FFE0B2; color: #F57C00; }
    .badge-malo { background-color: #FFCDD2; color: #D32F2F; }
    .footer { background: #f8f9fa; padding: 20px 30px; text-align: center; color: #666; font-size: 14px; }
    .footer strong { color: #1565C0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🌳 Resumen Diario de Áreas Verdes</h1>
      <p>Municipalidad de Doñihue - ${fecha}</p>
    </div>
    
    <div class="content">
      <div class="stats-grid">
        <div class="stat-card">
          <h3>Inspecciones Técnicas</h3>
          <div class="number">${totalInspecciones}</div>
          ${totalInspecciones > 0 ? `
            <div style="margin-top: 10px; font-size: 14px;">
              <span class="badge badge-bueno">${inspeccionesBuenas} Bueno</span>
              <span class="badge badge-regular">${inspeccionesRegulares} Regular</span>
              <span class="badge badge-malo">${inspeccionesMalas} Malo</span>
            </div>
          ` : ''}
        </div>
        
        <div class="stat-card">
          <h3>Catastros de Inmuebles</h3>
          <div class="number">${totalCatastros}</div>
          ${totalCatastros > 0 ? `
            <div style="margin-top: 10px; font-size: 14px;">
              <span class="badge badge-bueno">${catastrosBuenos} Bueno</span>
              <span class="badge badge-regular">${catastrosRegulares} Regular</span>
              <span class="badge badge-malo">${catastrosMalos} Malo</span>
            </div>
          ` : ''}
        </div>
      </div>
      
      ${totalInspecciones > 0 ? `
        <div class="section">
          <div class="section-title">📋 Inspecciones Técnicas Realizadas</div>
          ${inspecciones.map(insp => `
            <div class="item">
              <div class="item-title">
                ${insp.nombre_plaza || 'Plaza sin nombre'}
                <span class="badge badge-${insp.estado_general?.toLowerCase() || 'regular'}">${insp.estado_general || 'N/A'}</span>
              </div>
              <div class="item-details">
                🕒 ${insp.fecha_legible || 'Sin fecha'} | 
                👤 Inspector: ${insp.nombre_inspector || 'No especificado'}
              </div>
            </div>
          `).join('')}
        </div>
      ` : ''}
      
      ${totalCatastros > 0 ? `
        <div class="section">
          <div class="section-title">🏢 Catastros de Inmuebles Realizados</div>
          ${catastros.map(cat => `
            <div class="item">
              <div class="item-title">
                ${cat.nombre_plaza || 'Plaza sin nombre'}
                <span class="badge badge-${cat.estado_general?.toLowerCase() || 'regular'}">${cat.estado_general || 'N/A'}</span>
              </div>
              <div class="item-details">
                🕒 ${cat.fecha_legible || 'Sin fecha'} | 
                👤 Inspector: ${cat.inspector || 'No especificado'}
              </div>
            </div>
          `).join('')}
        </div>
      ` : ''}
    </div>
    
    <div class="footer">
      <p><strong>Felipe Lagos Bastias</strong> - Ingeniero Agrónomo</p>
      <p>Encargado de Áreas Verdes y Ornato</p>
      <p style="margin-top: 10px; font-size: 12px; color: #999;">
        Sistema de Gestión de Áreas Verdes - Municipalidad de Doñihue © ${new Date().getFullYear()}
      </p>
    </div>
  </div>
</body>
</html>
  `;
}

// Función para generar versión texto plano
function generarResumenTexto(inspecciones, catastros, fecha) {
  let texto = `RESUMEN DIARIO DE ÁREAS VERDES\nMunicipalidad de Doñihue - ${fecha}\n\n`;
  
  texto += `INSPECCIONES TÉCNICAS: ${inspecciones.length}\n`;
  if (inspecciones.length > 0) {
    inspecciones.forEach((insp, i) => {
      texto += `${i + 1}. ${insp.nombre_plaza} - ${insp.estado_general} (${insp.fecha_legible})\n`;
    });
  }
  
  texto += `\nCATASTROS DE INMUEBLES: ${catastros.length}\n`;
  if (catastros.length > 0) {
    catastros.forEach((cat, i) => {
      texto += `${i + 1}. ${cat.nombre_plaza} - ${cat.estado_general} (${cat.fecha_legible})\n`;
    });
  }
  
  texto += `\n---\nFelipe Lagos Bastias - Ingeniero Agrónomo\nEncargado de Áreas Verdes y Ornato\nMunicipalidad de Doñihue`;
  
  return texto;
}
