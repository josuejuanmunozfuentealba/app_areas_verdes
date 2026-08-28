// Edge Function: convert-pdf-to-word-convertapi
// Convierte PDF a Word usando ConvertAPI v2 REST
// Migrado desde iLovePDF el 27/08/2026 (iLovePDF no tiene PDF→Word en API)

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const CONVERTAPI_SECRET = Deno.env.get("CONVERTAPI_SECRET");
const CONVERTAPI_URL = "https://v2.convertapi.com/convert/pdf/to/docx";

interface ConversionRequest {
  pdfBase64: string;
  filename: string;
}

// Función principal de conversión usando ConvertAPI v2 REST
async function convertPdfToWord(pdfBase64: string, filename: string): Promise<string> {
  console.log("[ConvertAPI] Iniciando conversión:", filename);

  if (!CONVERTAPI_SECRET) {
    throw new Error("CONVERTAPI_SECRET no configurada en los secretos de Supabase");
  }

  // Decodificar base64 a bytes
  const pdfBytes = Uint8Array.from(atob(pdfBase64), c => c.charCodeAt(0));
  const blob = new Blob([pdfBytes], { type: "application/pdf" });

  // Convertir Blob a Base64 para enviar a ConvertAPI
  const reader = new FileReader();
  const base64Promise = new Promise<string>((resolve, reject) => {
    reader.onloadend = () => {
      const base64String = (reader.result as string).split(',')[1];
      resolve(base64String);
    };
    reader.onerror = reject;
    reader.readAsDataURL(blob);
  });

  const fileBase64 = await base64Promise;

  console.log("[ConvertAPI] PDF size:", Math.round(pdfBytes.length / 1024), "KB");
  console.log("[ConvertAPI] Llamando a API...");

  // Llamar a ConvertAPI v2 REST
  const response = await fetch(CONVERTAPI_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${CONVERTAPI_SECRET}`,
    },
    body: JSON.stringify({
      Parameters: [
        {
          Name: "File",
          FileValue: {
            Name: filename,
            Data: fileBase64,
          },
        },
        {
          Name: "StoreFile",
          Value: true,
        },
      ],
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error("[ConvertAPI] Error response:", errorText);
    throw new Error(`ConvertAPI failed: ${response.status} - ${errorText}`);
  }

  const data = await response.json();

  // Validar respuesta
  if (!data.Files || data.Files.length === 0) {
    console.error("[ConvertAPI] Respuesta inválida:", data);
    throw new Error(data.Message || "No se generó archivo DOCX");
  }

  const docxUrl = data.Files[0].Url;

  console.log("[ConvertAPI] ✅ Conversión exitosa");
  console.log("[ConvertAPI] DOCX URL:", docxUrl);

  return docxUrl;
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

    console.log("[ConvertAPI] Nueva solicitud:", filename);
    console.log("[ConvertAPI] Tamaño PDF:", Math.round(pdfBase64.length * 0.75 / 1024), "KB");

    // Ejecutar conversión
    const downloadUrl = await convertPdfToWord(pdfBase64, filename);

    // Respuesta exitosa
    return new Response(
      JSON.stringify({
        success: true,
        docxUrl: downloadUrl,
        wordUrl: downloadUrl, // Alias para compatibilidad
        docxFilename: filename.replace(".pdf", ".docx"),
        message: "Conversión exitosa con ConvertAPI"
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );

  } catch (error) {
    console.error("[ConvertAPI] ❌ Error:", error);

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
