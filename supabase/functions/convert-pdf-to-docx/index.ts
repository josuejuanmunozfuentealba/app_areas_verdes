// Supabase Edge Function: Convertir PDF a DOCX usando CloudConvert API
// Proyecto: App Áreas Verdes Doñihue - Módulo Catastro de Inmuebles

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const CLOUDCONVERT_API_KEY = Deno.env.get('CLOUDCONVERT_API_KEY');
const CLOUDCONVERT_API_BASE = 'https://api.cloudconvert.com/v2';

interface ConversionRequest {
  pdfBase64: string;
  filename?: string;
}

interface ConversionResponse {
  success: boolean;
  docxUrl?: string;
  docxFilename?: string;
  error?: string;
  message?: string;
}

serve(async (req: Request): Promise<Response> => {
  // CORS headers para permitir requests desde Flutter
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  };

  // Manejar preflight OPTIONS request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Verificar que API Key esté configurada
    if (!CLOUDCONVERT_API_KEY) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'CloudConvert API Key not configured',
          message: 'CLOUDCONVERT_API_KEY environment variable is missing'
        } as ConversionResponse),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Verificar método HTTP
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Method not allowed',
          message: 'Only POST method is supported'
        } as ConversionResponse),
        {
          status: 405,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // Parsear request body
    const body: ConversionRequest = await req.json();
    const { pdfBase64, filename = 'document.pdf' } = body;

    if (!pdfBase64) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Missing PDF data',
          message: 'pdfBase64 field is required'
        } as ConversionResponse),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    console.log(`[CloudConvert] Starting conversion for: ${filename}`);

    // Decodificar base64 a bytes
    const pdfBytes = Uint8Array.from(atob(pdfBase64), c => c.charCodeAt(0));
    console.log(`[CloudConvert] PDF size: ${pdfBytes.length} bytes`);

    // PASO 1: Crear job en CloudConvert
    console.log('[CloudConvert] Creating job...');
    const jobResponse = await fetch(`${CLOUDCONVERT_API_BASE}/jobs`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${CLOUDCONVERT_API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        tasks: {
          'import-pdf': {
            operation: 'import/upload'
          },
          'convert-to-docx': {
            operation: 'convert',
            input: 'import-pdf',
            output_format: 'docx'
          },
          'export-docx': {
            operation: 'export/url',
            input: 'convert-to-docx'
          }
        }
      })
    });

    if (!jobResponse.ok) {
      const errorText = await jobResponse.text();
      console.error('[CloudConvert] Job creation failed:', errorText);
      return new Response(
        JSON.stringify({
          success: false,
          error: 'CloudConvert job creation failed',
          message: `Status: ${jobResponse.status}, ${errorText}`
        } as ConversionResponse),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    const job = await jobResponse.json();
    const jobId = job.data.id;
    console.log(`[CloudConvert] Job created: ${jobId}`);

    // Encontrar tarea de upload
    const uploadTask = job.data.tasks.find((t: any) => t.name === 'import-pdf');
    if (!uploadTask || !uploadTask.result?.form) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Upload task not found',
          message: 'CloudConvert did not return upload URL'
        } as ConversionResponse),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // PASO 2: Subir PDF
    console.log('[CloudConvert] Uploading PDF...');
    const uploadUrl = uploadTask.result.form.url;
    const uploadParameters = uploadTask.result.form.parameters;

    // Crear FormData para multipart upload
    const formData = new FormData();
    Object.keys(uploadParameters).forEach(key => {
      formData.append(key, uploadParameters[key]);
    });
    formData.append('file', new Blob([pdfBytes], { type: 'application/pdf' }), filename);

    const uploadResponse = await fetch(uploadUrl, {
      method: 'POST',
      body: formData
    });

    if (!uploadResponse.ok) {
      const errorText = await uploadResponse.text();
      console.error('[CloudConvert] Upload failed:', errorText);
      return new Response(
        JSON.stringify({
          success: false,
          error: 'PDF upload failed',
          message: `Status: ${uploadResponse.status}, ${errorText}`
        } as ConversionResponse),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    console.log('[CloudConvert] PDF uploaded successfully');

    // PASO 3: Esperar a que el job termine (polling)
    console.log('[CloudConvert] Waiting for job to complete...');
    let jobStatus = 'processing';
    let attempts = 0;
    const maxAttempts = 60; // 5 minutos máximo (60 intentos * 5 segundos)
    let finalJob: any = null;

    while (jobStatus === 'processing' && attempts < maxAttempts) {
      await new Promise(resolve => setTimeout(resolve, 5000)); // Esperar 5 segundos

      const statusResponse = await fetch(`${CLOUDCONVERT_API_BASE}/jobs/${jobId}`, {
        headers: {
          'Authorization': `Bearer ${CLOUDCONVERT_API_KEY}`
        }
      });

      if (!statusResponse.ok) {
        console.error('[CloudConvert] Failed to check status');
        break;
      }

      finalJob = await statusResponse.json();
      jobStatus = finalJob.data.status;
      attempts++;

      console.log(`[CloudConvert] Status: ${jobStatus} (attempt ${attempts}/${maxAttempts})`);
    }

    if (jobStatus !== 'finished') {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Conversion timeout or failed',
          message: `Job status: ${jobStatus} after ${attempts} attempts`
        } as ConversionResponse),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    // PASO 4: Obtener URL del DOCX
    const exportTask = finalJob.data.tasks.find((t: any) => t.name === 'export-docx');
    if (!exportTask || !exportTask.result?.files?.[0]?.url) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Export task not found',
          message: 'CloudConvert did not return DOCX URL'
        } as ConversionResponse),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    const docxUrl = exportTask.result.files[0].url;
    const docxFilename = exportTask.result.files[0].filename;

    console.log(`[CloudConvert] Conversion successful: ${docxFilename}`);
    console.log(`[CloudConvert] DOCX URL: ${docxUrl}`);

    // Retornar respuesta exitosa
    return new Response(
      JSON.stringify({
        success: true,
        docxUrl,
        docxFilename,
        message: 'Conversion completed successfully'
      } as ConversionResponse),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );

  } catch (error) {
    console.error('[CloudConvert] Unexpected error:', error);
    return new Response(
      JSON.stringify({
        success: false,
        error: 'Internal server error',
        message: error instanceof Error ? error.message : String(error)
      } as ConversionResponse),
      {
        status: 500,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json'
        }
      }
    );
  }
});
