const express = require('express');
const nodemailer = require('nodemailer');
const cors = require('cors');
const multer = require('multer');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Configurar almacenamiento temporal para archivos
const storage = multer.memoryStorage();
const upload = multer({ storage: storage, limits: { fileSize: 50 * 1024 * 1024 } });

// Configurar transportador de correo
// IMPORTANTE: Debes configurar las variables de entorno en el archivo .env
const transporter = nodemailer.createTransport({
  service: 'gmail', // o 'outlook', 'yahoo', etc.
  auth: {
    user: process.env.EMAIL_USER, // Tu correo
    pass: process.env.EMAIL_PASSWORD // Tu contraseña de aplicación
  }
});

// Verificar configuración del transportador
transporter.verify((error, success) => {
  if (error) {
    console.error('❌ Error en configuración de correo:', error);
  } else {
    console.log('✅ Servidor de correo configurado correctamente');
  }
});

// Endpoint para enviar correo con PDF adjunto
app.post('/api/send-email', upload.single('pdf'), async (req, res) => {
  try {
    const { 
      destinatario, 
      asunto, 
      cuerpo,
      nombreArchivo 
    } = req.body;

    // Validar datos
    if (!destinatario || !asunto || !cuerpo) {
      return res.status(400).json({ 
        success: false, 
        error: 'Faltan datos requeridos: destinatario, asunto o cuerpo' 
      });
    }

    // Preparar opciones del correo
    const mailOptions = {
      from: `"Sistema Inspección Áreas Verdes" <${process.env.EMAIL_USER}>`,
      to: destinatario,
      subject: asunto,
      text: cuerpo,
      html: `<pre style="font-family: Arial, sans-serif; white-space: pre-wrap;">${cuerpo}</pre>`,
      attachments: []
    };

    // Agregar PDF si existe
    if (req.file) {
      mailOptions.attachments.push({
        filename: nombreArchivo || 'reporte.pdf',
        content: req.file.buffer,
        contentType: 'application/pdf'
      });
    }

    // Enviar correo
    const info = await transporter.sendMail(mailOptions);

    console.log('✅ Correo enviado:', info.messageId);
    res.json({ 
      success: true, 
      messageId: info.messageId,
      message: 'Correo enviado exitosamente' 
    });

  } catch (error) {
    console.error('❌ Error al enviar correo:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// Endpoint alternativo: enviar correo con PDF en base64
app.post('/api/send-email-base64', async (req, res) => {
  try {
    const { 
      destinatario, 
      asunto, 
      cuerpo,
      pdfBase64,
      nombreArchivo 
    } = req.body;

    // Validar datos
    if (!destinatario || !asunto || !cuerpo) {
      return res.status(400).json({ 
        success: false, 
        error: 'Faltan datos requeridos' 
      });
    }

    // Preparar opciones del correo
    const mailOptions = {
      from: `"Sistema Inspección Áreas Verdes" <${process.env.EMAIL_USER}>`,
      to: destinatario,
      subject: asunto,
      text: cuerpo,
      html: `<pre style="font-family: Arial, sans-serif; white-space: pre-wrap;">${cuerpo}</pre>`,
      attachments: []
    };

    // Agregar PDF desde base64 si existe
    if (pdfBase64) {
      mailOptions.attachments.push({
        filename: nombreArchivo || 'reporte.pdf',
        content: Buffer.from(pdfBase64, 'base64'),
        contentType: 'application/pdf'
      });
    }

    // Enviar correo
    const info = await transporter.sendMail(mailOptions);

    console.log('✅ Correo enviado:', info.messageId);
    res.json({ 
      success: true, 
      messageId: info.messageId,
      message: 'Correo enviado exitosamente' 
    });

  } catch (error) {
    console.error('❌ Error al enviar correo:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// Endpoint de prueba
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'Servidor funcionando correctamente',
    timestamp: new Date().toISOString()
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`🚀 Servidor iniciado en http://localhost:${PORT}`);
  console.log(`📧 Endpoint: POST http://localhost:${PORT}/api/send-email-base64`);
});
