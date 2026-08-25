// API Serverless para envío de resúmenes por correo en Vercel
// Esta función maneja el endpoint /api/send-summary

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
      to, 
      nombrePlaza, 
      plazaId, 
      fecha, 
      estadoGeneral, 
      problemasTexto 
    } = req.body;

    // Validar campos requeridos
    if (!to || !nombrePlaza) {
      return res.status(400).json({ 
        error: 'Faltan campos requeridos',
        required: ['to', 'nombrePlaza']
      });
    }

    // Generar asunto y cuerpo del correo
    const subject = `Reporte de Inspección - ${nombrePlaza}`;
    
    const htmlBody = `
      <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .header { background-color: #1565C0; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; }
            .info-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
            .info-table td { padding: 10px; border: 1px solid #ddd; }
            .info-table td:first-child { background-color: #f5f5f5; font-weight: bold; width: 40%; }
            .problemas { background-color: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 20px 0; }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
          </style>
        </head>
        <body>
          <div class="header">
            <h1>🌳 Reporte de Inspección Técnica</h1>
            <p>Municipalidad de Doñihue - Áreas Verdes</p>
          </div>
          
          <div class="content">
            <h2>Información General</h2>
            <table class="info-table">
              <tr>
                <td>Plaza</td>
                <td><strong>${nombrePlaza}</strong></td>
              </tr>
              <tr>
                <td>ID</td>
                <td>${plazaId || 'N/A'}</td>
              </tr>
              <tr>
                <td>Fecha de Inspección</td>
                <td>${fecha || new Date().toLocaleDateString('es-CL')}</td>
              </tr>
              <tr>
                <td>Estado General</td>
                <td><strong style="color: ${estadoGeneral === 'Bueno' ? '#2E7D32' : estadoGeneral === 'Regular' ? '#F57C00' : '#D32F2F'};">${estadoGeneral || 'N/A'}</strong></td>
              </tr>
            </table>
            
            ${problemasTexto ? `
              <div class="problemas">
                <h3>⚠️ Observaciones y Problemas Detectados</h3>
                <pre style="white-space: pre-wrap; font-family: Arial, sans-serif;">${problemasTexto}</pre>
              </div>
            ` : '<p>✅ No se detectaron problemas significativos.</p>'}
            
            <p><em>Este es un resumen automático del reporte de inspección. Los archivos PDF y Word con el detalle completo fueron generados localmente.</em></p>
          </div>
          
          <div class="footer">
            <p>Sistema de Gestión de Áreas Verdes</p>
            <p>Municipalidad de Doñihue © ${new Date().getFullYear()}</p>
            <p>Encargado: Felipe Lagos Bastias - Ingeniero Agrónomo</p>
          </div>
        </body>
      </html>
    `;

    // Configurar transporte de correo
    const transporter = nodemailer.createTransporter({
      host: process.env.SMTP_HOST || 'smtp.gmail.com',
      port: parseInt(process.env.SMTP_PORT || '587'),
      secure: process.env.SMTP_SECURE === 'true',
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
    });

    // Enviar correo
    const info = await transporter.sendMail({
      from: process.env.SMTP_USER,
      to: to,
      subject: subject,
      html: htmlBody,
      text: `
Reporte de Inspección - ${nombrePlaza}

Plaza: ${nombrePlaza}
ID: ${plazaId || 'N/A'}
Fecha: ${fecha || new Date().toLocaleDateString('es-CL')}
Estado General: ${estadoGeneral || 'N/A'}

${problemasTexto || 'No se detectaron problemas significativos.'}

---
Sistema de Gestión de Áreas Verdes
Municipalidad de Doñihue
      `.trim(),
    });

    return res.status(200).json({
      success: true,
      message: 'Resumen enviado exitosamente',
      messageId: info.messageId,
    });

  } catch (error) {
    console.error('Error al enviar resumen:', error);
    return res.status(500).json({
      success: false,
      error: 'Error al enviar el resumen',
      details: error.message,
    });
  }
};
