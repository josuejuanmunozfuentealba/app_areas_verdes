// API Serverless para envío de correos formales en Vercel
// Endpoint: /api/send-email
// Envía informes de Inspección Técnica o Catastro con formato formal

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

  // Solo permitir POST
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido' });
  }

  try {
    const {
      nombreInspector,
      nombrePlaza,
      estadoGeneral,
      fecha,
      tipoInforme, // 'inspeccion' o 'catastro'
      pdfUrl,
      wordUrl,
      attachments // Mantener para compatibilidad retroactiva
    } = req.body;

    // Validar campos requeridos
    if (!nombreInspector || !nombrePlaza || !fecha || !tipoInforme) {
      return res.status(400).json({
        error: 'Faltan campos requeridos',
        required: ['nombreInspector', 'nombrePlaza', 'fecha', 'tipoInforme']
      });
    }

    // Generar asunto formal
    const tipoTexto = tipoInforme === 'inspeccion' 
      ? 'Inspección Técnica' 
      : 'Catastro de Inmuebles';
    const subject = `${tipoTexto}: ${nombrePlaza} - ${fecha}`;

    // Generar cuerpo HTML formal
    const htmlBody = generarCuerpoFormal({
      nombreInspector,
      nombrePlaza,
      estadoGeneral,
      fecha,
      tipoInforme
    });

    // Configurar transporte SMTP
    const smtpUser = process.env.GMAIL_USER;
    const smtpPass = process.env.GMAIL_APP_PASSWORD;
    
    // Debug: Log para verificar credenciales (sin mostrar la contraseña completa)
    console.log('🔍 Verificando credenciales SMTP:');
    console.log('- GMAIL_USER:', smtpUser ? `${smtpUser.substring(0, 3)}***` : 'NO DEFINIDO');
    console.log('- GMAIL_APP_PASSWORD:', smtpPass ? 'DEFINIDO (oculto)' : 'NO DEFINIDO');
    
    if (!smtpUser || !smtpPass) {
      throw new Error('Credenciales SMTP no configuradas. Verifica las variables de entorno GMAIL_USER y GMAIL_APP_PASSWORD');
    }

    const transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST || 'smtp.gmail.com',
      port: parseInt(process.env.SMTP_PORT || '587'),
      secure: process.env.SMTP_SECURE === 'true',
      auth: {
        user: smtpUser,
        pass: smtpPass,
      },
    });

    // Preparar opciones de correo
    const mailOptions = {
      from: `"Sistema Áreas Verdes Doñihue" <${smtpUser}>`,
      to: 'flagos@mdonihue.cl, aseoornatodonihue@gmail.com',
      subject: subject,
      html: htmlBody,
      text: generarCuerpoTextoPlano({
        nombreInspector,
        nombrePlaza,
        estadoGeneral,
        fecha,
        tipoInforme
      }),
    };

    // Prioridad 1: Usar URLs de Supabase (más eficiente, evita payload grande)
    if (pdfUrl || wordUrl) {
      mailOptions.attachments = [];
      
      // Descargar archivos desde Supabase y adjuntarlos
      if (pdfUrl) {
        try {
          const pdfResponse = await fetch(pdfUrl);
          const pdfBuffer = Buffer.from(await pdfResponse.arrayBuffer());
          mailOptions.attachments.push({
            filename: `${tipoInforme}_${nombrePlaza.replace(/\s+/g, '_')}.pdf`,
            content: pdfBuffer,
            contentType: 'application/pdf'
          });
        } catch (error) {
          console.error('Error descargando PDF:', error);
        }
      }
      
      if (wordUrl) {
        try {
          const wordResponse = await fetch(wordUrl);
          const wordBuffer = Buffer.from(await wordResponse.arrayBuffer());
          mailOptions.attachments.push({
            filename: `${tipoInforme}_${nombrePlaza.replace(/\s+/g, '_')}.docx`,
            content: wordBuffer,
            contentType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          });
        } catch (error) {
          console.error('Error descargando Word:', error);
        }
      }
    }
    // Prioridad 2: Usar attachments en base64 (compatibilidad retroactiva)
    else if (attachments && Array.isArray(attachments) && attachments.length > 0) {
      mailOptions.attachments = attachments.map(att => ({
        filename: att.filename,
        content: Buffer.from(att.content, 'base64'),
        contentType: att.contentType || 'application/octet-stream'
      }));
    }

    // Enviar correo
    const info = await transporter.sendMail(mailOptions);

    // Actualizar en Supabase: correo_enviado = true
    const registroId = req.body.registroId;
    const tipoTabla = tipoInforme === 'inspeccion' 
      ? 'inspecciones_tecnicas' 
      : 'catastros_inmuebles';

    if (registroId) {
      const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
      const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

      if (supabaseUrl && supabaseKey) {
        try {
          await fetch(
            `${supabaseUrl}/rest/v1/${tipoTabla}?id=eq.${registroId}`,
            {
              method: 'PATCH',
              headers: {
                'apikey': supabaseKey,
                'Authorization': `Bearer ${supabaseKey}`,
                'Content-Type': 'application/json',
                'Prefer': 'return=minimal'
              },
              body: JSON.stringify({
                correo_enviado: true,
                fecha_envio_correo: new Date().toISOString()
              })
            }
          );
        } catch (updateError) {
          console.error('Error al actualizar Supabase:', updateError);
          // No falla el envío si la actualización falla
        }
      }
    }

    return res.status(200).json({
      success: true,
      message: 'Correo enviado exitosamente a Felipe Lagos Bastias',
      messageId: info.messageId,
      fecha: fecha,
      supabaseUpdated: !!registroId,
    });

  } catch (error) {
    console.error('Error al enviar correo:', error);
    return res.status(500).json({
      success: false,
      error: 'Error al enviar el correo',
      details: error.message,
    });
  }
};

// Función para generar el cuerpo HTML formal
function generarCuerpoFormal({ nombreInspector, nombrePlaza, estadoGeneral, fecha, tipoInforme }) {
  const tipoTexto = tipoInforme === 'inspeccion' 
    ? 'Inspección Técnica de Áreas Verdes' 
    : 'Catastro de Inmuebles de Áreas Verdes';
  
  const estadoBadge = estadoGeneral 
    ? `<span style="display: inline-block; padding: 6px 16px; border-radius: 20px; font-weight: 600; font-size: 14px; ${
        estadoGeneral === 'Bueno' 
          ? 'background-color: #C8E6C9; color: #2E7D32;'
          : estadoGeneral === 'Regular'
          ? 'background-color: #FFE0B2; color: #F57C00;'
          : 'background-color: #FFCDD2; color: #D32F2F;'
      }">${estadoGeneral}</span>`
    : '';

  return `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; background-color: #f5f5f5; margin: 0; padding: 20px; }
    .container { max-width: 700px; margin: 0 auto; background-color: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); overflow: hidden; }
    .header { background: linear-gradient(135deg, #1565C0 0%, #0D47A1 100%); color: white; padding: 30px; text-align: center; }
    .header h1 { margin: 0; font-size: 24px; font-weight: 600; }
    .header p { margin: 8px 0 0 0; font-size: 14px; opacity: 0.9; }
    .content { padding: 30px; }
    .saludo { font-size: 16px; margin-bottom: 20px; line-height: 1.8; }
    .info-box { background: #f8f9fa; border-left: 4px solid #1565C0; padding: 20px; margin: 20px 0; border-radius: 4px; }
    .info-row { display: flex; margin-bottom: 12px; }
    .info-label { font-weight: 600; color: #555; min-width: 140px; }
    .info-value { color: #333; }
    .adjuntos { background: #E3F2FD; padding: 15px; border-radius: 4px; margin: 20px 0; }
    .adjuntos-title { font-weight: 600; color: #1565C0; margin-bottom: 10px; }
    .adjuntos-list { font-size: 14px; color: #555; line-height: 1.8; }
    .firma { margin-top: 30px; padding-top: 20px; border-top: 1px solid #e0e0e0; }
    .firma p { margin: 5px 0; }
    .footer { background: #f8f9fa; padding: 20px 30px; text-align: center; color: #666; font-size: 12px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🌳 ${tipoTexto}</h1>
      <p>Municipalidad de Doñihue</p>
    </div>
    
    <div class="content">
      <div class="saludo">
        <strong>Felipe Lagos Bastias</strong><br>
        Ingeniero Agrónomo<br>
        Encargado de Áreas Verdes y Ornato<br>
        Municipalidad de Doñihue
      </div>
      
      <p style="margin: 20px 0;">Estimado Sr. Lagos:</p>
      
      <p style="line-height: 1.8;">
        Por medio del presente, me dirijo a usted para informarle que se ha completado el ${tipoTexto.toLowerCase()} 
        correspondiente a <strong>${nombrePlaza}</strong>.
      </p>
      
      <div class="info-box">
        <div class="info-row">
          <div class="info-label">📍 Plaza:</div>
          <div class="info-value">${nombrePlaza}</div>
        </div>
        <div class="info-row">
          <div class="info-label">📅 Fecha:</div>
          <div class="info-value">${fecha}</div>
        </div>
        ${estadoGeneral ? `
        <div class="info-row">
          <div class="info-label">📊 Estado General:</div>
          <div class="info-value">${estadoBadge}</div>
        </div>
        ` : ''}
        <div class="info-row">
          <div class="info-label">👤 Inspector:</div>
          <div class="info-value">${nombreInspector}</div>
        </div>
      </div>
      
      <div class="adjuntos">
        <div class="adjuntos-title">📎 Documentos Adjuntos:</div>
        <div class="adjuntos-list">
          • Informe en formato PDF (para visualización e impresión)<br>
          • Informe en formato Word (editable, incluye evidencia fotográfica y observaciones detalladas)
        </div>
      </div>
      
      <p style="line-height: 1.8;">
        Los documentos adjuntos contienen el detalle completo de la evaluación realizada, 
        incluyendo los criterios técnicos evaluados, observaciones específicas y evidencia fotográfica.
      </p>
      
      <p style="line-height: 1.8;">
        Quedo atento a cualquier consulta o aclaración que requiera sobre este informe.
      </p>
      
      <div class="firma">
        <p><strong>Atentamente,</strong></p>
        <p style="margin-top: 15px;">
          <strong>${nombreInspector}</strong><br>
          Inspector de Áreas Verdes<br>
          Municipalidad de Doñihue
        </p>
      </div>
    </div>
    
    <div class="footer">
      Sistema de Gestión de Áreas Verdes - Municipalidad de Doñihue © ${new Date().getFullYear()}
    </div>
  </div>
</body>
</html>
  `;
}

// Función para generar versión texto plano
function generarCuerpoTextoPlano({ nombreInspector, nombrePlaza, estadoGeneral, fecha, tipoInforme }) {
  const tipoTexto = tipoInforme === 'inspeccion' 
    ? 'Inspección Técnica de Áreas Verdes' 
    : 'Catastro de Inmuebles de Áreas Verdes';

  return `
${tipoTexto.toUpperCase()}
Municipalidad de Doñihue

Felipe Lagos Bastias
Ingeniero Agrónomo
Encargado de Áreas Verdes y Ornato
Municipalidad de Doñihue

Estimado Sr. Lagos:

Por medio del presente, me dirijo a usted para informarle que se ha completado el ${tipoTexto.toLowerCase()} correspondiente a ${nombrePlaza}.

INFORMACIÓN DEL INFORME:
• Plaza: ${nombrePlaza}
• Fecha: ${fecha}
${estadoGeneral ? `• Estado General: ${estadoGeneral}\n` : ''}• Inspector: ${nombreInspector}

DOCUMENTOS ADJUNTOS:
• Informe en formato PDF (para visualización e impresión)
• Informe en formato Word (editable, incluye evidencia fotográfica y observaciones detalladas)

Los documentos adjuntos contienen el detalle completo de la evaluación realizada, incluyendo los criterios técnicos evaluados, observaciones específicas y evidencia fotográfica.

Quedo atento a cualquier consulta o aclaración que requiera sobre este informe.

Atentamente,

${nombreInspector}
Inspector de Áreas Verdes
Municipalidad de Doñihue

---
Sistema de Gestión de Áreas Verdes - Municipalidad de Doñihue © ${new Date().getFullYear()}
  `;
}
