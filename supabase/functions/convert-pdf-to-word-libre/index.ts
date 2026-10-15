// Edge Function: convert-pdf-to-word-libre  
// Convierte PDF a Word usando LibreOffice (GRATIS, sin límites)
// Alternativa a ConvertAPI cuando expira el plan gratuito

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

interface ConversionRequest {
  pdfBase64: string;
  filename: string;
}

// Función para convertir PDF a Word usando LibreOffice
async function convertPdfToWordLibre(pdfBase64: string, filename: string): Promise<Uint8List> {
  console.log("[LibreOffice] Iniciando conversión:", filename);

  // Decodificar PDF desde Base64
  const pdfBytes = Uint8Array.from(atob(pdfBase64), c => c.charCodeAt(0));
  console.log("[LibreOffice] PDF size:", Math.round(pdfBytes.length / 1024), "KB");

  // Crear archivo temporal para el PDF
  const pdfPath = `/tmp/input_${Date.now()}.pdf`;
  const docxPath = `/tmp/output_${Date.now()}.docx`;

  try {
    // Escribir PDF al sistema de archivos temporal
    await Deno.writeFile(pdfPath, pdfBytes);
    console.log("[LibreOffice] PDF guardado en:", pdfPath);

    // Ejecutar LibreOffice para convertir PDF a DOCX
    const command = new Deno.Command("libreoffice", {
      args: [
        "--headless",
        "--convert-to", "docx",
        "--outdir", "/tmp",
        pdfPath
      ],
      stdout: "piped",
      stderr: "piped"
    });

    console.log("[LibreOffice] Ejecutando conversión...");
    const { code, stdout, stderr } = await command.output();

    if (code !== 0) {
      const error = new TextDecoder().decode(stderr);
      console.error("[LibreOffice] Error:", error);
      throw new Error(`LibreOffice falló: ${error}`);
    }

    console.log("[LibreOffice] ✅ Conversión exitosa");

    // Leer el archivo DOCX generado
    const docxBytes = await Deno.readFile(docxPath);
    console.log("[LibreOffice] DOCX size:", Math.round(docxBytes.length / 1024), "KB");

    // Limpiar archivos temporales
    try {
      await Deno.remove(pdfPath);
      await Deno.remove(docxPath);
    } catch (e) {
      console.warn("[LibreOffice] Error limpiando archivos temporales:", e);
    }

    return docxBytes;

  } catch (error) {
    // Limpiar archivos en caso de error
    try {
      await Deno.remove(pdfPath).catch(() => {});
      await Deno.remove(docxPath).catch(() => {});
    } catch {}
    
    throw error;
  }
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

    console.log("[LibreOffice] Nueva solicitud:", filename);

    // Ejecutar conversión
    const docxBytes = await convertPdfToWordLibre(pdfBase64, filename);

    // Respuesta con el archivo DOCX como Base64
    const docxBase64 = btoa(String.fromCharCode(...docxBytes));

    return new Response(
      JSON.stringify({
        success: true,
        docxBase64: docxBase64,
        docxFilename: filename.replace(".pdf", ".docx"),
        docxSize: docxBytes.length,
        message: "Conversión exitosa con LibreOffice (GRATIS)"
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );

  } catch (error) {
    console.error("[LibreOffice] ❌ Error:", error);

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message || "Unknown error",
        message: `Error de conversión: ${error.toString()}`,
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});