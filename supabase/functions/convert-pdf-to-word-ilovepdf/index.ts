// Edge Function: convert-pdf-to-word-ilovepdf
// Convierte PDF a Word usando iLovePDF API
// Migrado desde CloudConvert el 27/08/2026

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const ILOVEPDF_PUBLIC_KEY = Deno.env.get("ILOVEPDF_PUBLIC_KEY") || 
  "project_public_aa67e358d92ab536ad62c6a2701486d2_WXYNt07c4efe816c241a9462bbd2476da40c9";
const ILOVEPDF_SECRET_KEY = Deno.env.get("ILOVEPDF_SECRET_KEY") || 
  "secret_key_e431169b81c9bb9c61b1e4e651c4b3f1_sCh-L87ce3f0ab9f421388af8d0be0b3b06e";

const ILOVEPDF_API_URL = "https://api.ilovepdf.com/v1";

interface ConversionRequest {
  pdfBase64: string;
  filename: string;
}

// Función para obtener token de autenticación
async function getAuthToken(): Promise<string> {
  const response = await fetch(`${ILOVEPDF_API_URL}/auth`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      public_key: ILOVEPDF_PUBLIC_KEY,
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Auth failed: ${response.status} - ${error}`);
  }

  const data = await response.json();
  return data.token;
}

// Función principal de conversión
async function convertPdfToWord(pdfBase64: string, filename: string): Promise<string> {
  console.log("[iLovePDF] Iniciando conversión:", filename);

  // PASO 1: Autenticar y obtener token
  console.log("[iLovePDF] Paso 1/4: Autenticando...");
  const token = await getAuthToken();

  // PASO 2: Start task (pdftopdf - PDF to Word tool)
  console.log("[iLovePDF] Paso 2/4: Iniciando tarea PDF to Word...");
  const startResponse = await fetch(`${ILOVEPDF_API_URL}/start/pdftopdf`, {
    method: "GET",
    headers: {
      "Authorization": `Bearer ${token}`,
    },
  });

  if (!startResponse.ok) {
    const error = await startResponse.text();
    throw new Error(`Start task failed: ${startResponse.status} - ${error}`);
  }

  const taskData = await startResponse.json();
  const taskId = taskData.task;
  const serverFilename = taskData.server_filename;

  console.log("[iLovePDF] Task ID:", taskId);
  console.log("[iLovePDF] Server:", serverFilename);

  // PASO 3: Upload file
  console.log("[iLovePDF] Paso 3/4: Subiendo PDF...");
  
  // Decodificar base64 a bytes
  const pdfBytes = Uint8Array.from(atob(pdfBase64), c => c.charCodeAt(0));
  const blob = new Blob([pdfBytes], { type: "application/pdf" });

  const formData = new FormData();
  formData.append("task", taskId);
  formData.append("file", blob, filename);

  const uploadResponse = await fetch(`https://${serverFilename}/v1/upload`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${token}`,
    },
    body: formData,
  });

  if (!uploadResponse.ok) {
    const error = await uploadResponse.text();
    throw new Error(`Upload failed: ${uploadResponse.status} - ${error}`);
  }

  const uploadData = await uploadResponse.json();
  const serverFileId = uploadData.server_filename;

  console.log("[iLovePDF] Archivo subido:", serverFileId);

  // PASO 4: Process (convertir a Word)
  console.log("[iLovePDF] Paso 4/4: Procesando conversión a Word...");
  
  const processResponse = await fetch(`https://${serverFilename}/v1/process`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      task: taskId,
      tool: "pdftopdf", // Tool para convertir PDF a Word
      files: [{
        server_filename: serverFileId,
        filename: filename,
      }],
    }),
  });

  if (!processResponse.ok) {
    const error = await processResponse.text();
    throw new Error(`Process failed: ${processResponse.status} - ${error}`);
  }

  const processData = await processResponse.json();
  const downloadUrl = processData.download_url;

  console.log("[iLovePDF] ✅ Conversión exitosa");
  console.log("[iLovePDF] URL descarga:", downloadUrl);

  return downloadUrl;
}

// Servidor HTTP
serve(async (req) => {
  // CORS headers
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  };

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Validar método
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: "Method not allowed",
          message: "Solo se acepta POST"
        }),
        { 
          status: 405, 
          headers: { ...corsHeaders, "Content-Type": "application/json" } 
        }
      );
    }

    // Parsear body
    const body: ConversionRequest = await req.json();
    const { pdfBase64, filename } = body;

    // Validar parámetros
    if (!pdfBase64 || !filename) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Missing parameters",
          message: "Se requiere pdfBase64 y filename"
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, "Content-Type": "application/json" } 
        }
      );
    }

    console.log("[iLovePDF] Nueva solicitud:", filename);
    console.log("[iLovePDF] Tamaño PDF:", Math.round(pdfBase64.length * 0.75 / 1024), "KB");

    // Ejecutar conversión
    const downloadUrl = await convertPdfToWord(pdfBase64, filename);

    // Respuesta exitosa
    return new Response(
      JSON.stringify({
        success: true,
        docxUrl: downloadUrl,
        docxFilename: filename.replace(".pdf", ".docx"),
        message: "Conversión exitosa con iLovePDF"
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );

  } catch (error) {
    console.error("[iLovePDF] ❌ Error:", error);

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message || "Unknown error",
        message: error.toString(),
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
