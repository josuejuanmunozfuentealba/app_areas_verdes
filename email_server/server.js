const express = require('express');
const nodemailer = require('nodemailer');
const cors = require('cors');
const multer = require('multer');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Manejo de errores no capturados - evita que el servidor se cierre
process.on('uncaughtException', (error) => {
  console.error('============================================');
  console.error('⚠️  ERROR NO CAPTURADO');
  console.error('============================================');
  console.error(error);
  console.error('');
  console.error('El servidor continúa ejecutándose...');
  console.error('============================================');
  console.error('');
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('============================================');
  console.error('⚠️  PROMESA RECHAZADA NO MANEJADA');
  console.error('============================================');
  console.error('Razón:', reason);
  console.error('');
  console.error('El servidor continúa ejecutándose...');
  console.error('============================================');
  console.error('');
});

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
    pass: process.env.EMAIL_PASS || process.env.EMAIL_PASSWORD // Tu contraseña de aplicación
  }
});

// Verificar configuración del transportador (no bloquea el inicio)
transporter.verify((error, success) => {
  console.log('--------------------------------------------');
  console.log('📧 VERIFICACIÓN DE CREDENCIALES DE CORREO');
  console.log('--------------------------------------------');
  if (error) {
    console.error('❌ Error en configuración de correo:', error.message);
    console.error('');
    console.error('⚠️  ADVERTENCIA:');
    console.error('El servidor está activo, pero NO podrás enviar correos');
    console.error('hasta que configures correctamente las credenciales.');
    console.error('');
    console.error('Revisa el archivo .env y verifica:');
    console.error('1. EMAIL_USER tiene tu correo de Gmail');
    console.error('2. EMAIL_PASS tiene tu contraseña de aplicación');
    console.error('3. Has activado la verificación en dos pasos');
    console.error('4. Has generado una contraseña de aplicación en:');
    console.error('   https://myaccount.google.com/apppasswords');
    console.error('');
  } else {
    console.log('✅ Servidor de correo configurado correctamente');
    console.log('✅ Listo para enviar correos desde:', process.env.EMAIL_USER);
    console.log('');
  }
  console.log('--------------------------------------------');
  console.log('');
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

// Endpoint alternativo: enviar correo con múltiples archivos en base64
app.post('/api/send-email-multiple-attachments', async (req, res) => {
  try {
    const { 
      destinatario, 
      asunto, 
      cuerpo,
      adjuntos // Array de {nombre, base64}
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

    // Agregar adjuntos si existen
    if (adjuntos && Array.isArray(adjuntos)) {
      adjuntos.forEach(adjunto => {
        if (adjunto.base64 && adjunto.nombre) {
          mailOptions.attachments.push({
            filename: adjunto.nombre,
            content: Buffer.from(adjunto.base64, 'base64'),
            contentType: adjunto.tipo || 'application/octet-stream'
          });
        }
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
  console.log('============================================');
  console.log('🚀 SERVIDOR DE CORREOS ACTIVO');
  console.log('============================================');
  console.log(`📍 URL: http://localhost:${PORT}`);
  console.log(`📧 Endpoint principal: POST /api/send-email-base64`);
  console.log(`🏥 Health check: GET /api/health`);
  console.log('============================================');
  console.log('');
  console.log('✅ El servidor está escuchando en el puerto', PORT);
  console.log('⏳ Esperando peticiones...');
  console.log('');
  console.log('💡 Para detener el servidor presiona: Ctrl + C');
  console.log('');
}).on('error', (error) => {
  console.error('============================================');
  console.error('❌ ERROR AL INICIAR SERVIDOR');
  console.error('============================================');
  if (error.code === 'EADDRINUSE') {
    console.error(`El puerto ${PORT} ya está en uso.`);
    console.error('');
    console.error('Soluciones:');
    console.error('1. Cierra otras instancias del servidor');
    console.error('2. O usa otro puerto en el archivo .env');
    console.error('3. O ejecuta en CMD: netstat -ano | findstr :3000');
    console.error('   y cierra el proceso con: taskkill /PID <numero> /F');
  } else {
    console.error('Error:', error.message);
  }
  console.error('============================================');
  console.error('');
  process.exit(1);
});
