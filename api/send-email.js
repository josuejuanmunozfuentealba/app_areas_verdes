// API Serverless para envío de correos en Vercel
// Esta función maneja el endpoint /api/send-email

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
    const { to, subject, body, attachments } = req.body;

    // Validar campos requeridos
    if (!to || !subject || !body) {
      return res.status(400).json({ 
        error: 'Faltan campos requeridos',
        required: ['to', 'subject', 'body']
      });
    }

    // Configurar transporte de correo
    // NOTA: Configurar variables de entorno en Vercel
    const transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST || 'smtp.gmail.com',
      port: parseInt(process.env.SMTP_PORT || '587'),
      secure: process.env.SMTP_SECURE === 'true',
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
    });

    // Preparar opciones de correo
    const mailOptions = {
      from: process.env.SMTP_USER,
      to: to,
      subject: subject,
      html: body,
      text: body.replace(/<[^>]*>/g, ''), // Versión texto plano
    };

    // Agregar adjuntos si existen
    if (attachments && Array.isArray(attachments)) {
      mailOptions.attachments = attachments.map(att => ({
        filename: att.filename,
        content: Buffer.from(att.content, 'base64'),
        contentType: att.contentType || 'application/octet-stream'
      }));
    }

    // Enviar correo
    const info = await transporter.sendMail(mailOptions);

    return res.status(200).json({
      success: true,
      message: 'Correo enviado exitosamente',
      messageId: info.messageId,
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
