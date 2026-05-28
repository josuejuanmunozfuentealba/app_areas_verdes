; Script de Inno Setup para Áreas Verdes Doñihue
; Generado para crear instalador de Windows

#define MyAppName "Áreas Verdes Doñihue"
#define MyAppVersion "12.11"
#define MyAppPublisher "Josué Juan Muñoz Fuentealba"
#define MyAppExeName "ejecutar.vbs"
#define MyAppIcon "assets\iconoescri.ico"
#define MyAppURL "http://localhost:8080"

[Setup]
; Información de la aplicación
AppId={{A5B3C7D9-1234-5678-90AB-CDEF12345678}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\AreasVerdesDoñihue
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir=installer_output
OutputBaseFilename=AreasVerdesDoñihue_Setup_v{#MyAppVersion}
SetupIconFile={#MyAppIcon}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
UninstallDisplayIcon={app}\{#MyAppIcon}
; Cerrar aplicaciones antes de instalar
CloseApplications=yes
CloseApplicationsFilter=*.exe,*.hta

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "Crear un icono en el &escritorio"; GroupDescription: "Iconos adicionales:"

[Files]
; Archivos de la aplicación web compilada
Source: "build\web\*"; DestDir: "{app}\build\web"; Flags: ignoreversion recursesubdirs createallsubdirs
; Scripts de ejecución (ejecutar.vbs y precarga.hta se crearán dinámicamente)
Source: "ejecutar.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "iniciar_servidor.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "iniciar_servidor_simple.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "limpiar_cache_chrome.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "diagnostico.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "verificar_python.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "servidor.py"; DestDir: "{app}"; Flags: ignoreversion
; Archivos de datos
Source: "historial_data.json"; DestDir: "{app}"; Flags: ignoreversion
; Iconos y assets
Source: "assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; Icono en el menú de inicio
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppIcon}"
; Icono de diagnóstico en el menú de inicio
Name: "{group}\Diagnosticar Problemas"; Filename: "{app}\diagnostico.bat"; IconFilename: "{sys}\cmd.exe"
; Icono para limpiar cache
Name: "{group}\Limpiar Cache de Chrome"; Filename: "{app}\limpiar_cache_chrome.bat"; IconFilename: "{sys}\cmd.exe"
; Icono en el escritorio
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppIcon}"; Tasks: desktopicon
; Desinstalador en el menú de inicio
Name: "{group}\Desinstalar {#MyAppName}"; Filename: "{uninstallexe}"

[Run]
; Ejecutar la aplicación después de la instalación (opcional)
Filename: "{app}\{#MyAppExeName}"; Description: "Ejecutar {#MyAppName}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Limpiar archivos generados durante el uso
Type: files; Name: "{app}\historial_data.json"
Type: filesandordirs; Name: "{app}\build"

[Code]
function GetPythonPath(): String;
var
  PythonPath: String;
  ResultCode: Integer;
begin
  Result := '';
  
  // Buscar Python en PATH
  if Exec('cmd.exe', '/c python --version', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    if ResultCode = 0 then
    begin
      Result := 'python';
      Exit;
    end;
  end;
  
  // Buscar en ubicaciones comunes
  if FileExists('C:\Python312\python.exe') then
    Result := 'C:\Python312\python.exe'
  else if FileExists('C:\Python311\python.exe') then
    Result := 'C:\Python311\python.exe'
  else if FileExists('C:\Python310\python.exe') then
    Result := 'C:\Python310\python.exe'
  else if FileExists('C:\Python39\python.exe') then
    Result := 'C:\Python39\python.exe'
  else if FileExists('C:\Python38\python.exe') then
    Result := 'C:\Python38\python.exe'
  else if FileExists(ExpandConstant('{localappdata}\Programs\Python\Python312\python.exe')) then
    Result := ExpandConstant('{localappdata}\Programs\Python\Python312\python.exe')
  else if FileExists(ExpandConstant('{localappdata}\Programs\Python\Python311\python.exe')) then
    Result := ExpandConstant('{localappdata}\Programs\Python\Python311\python.exe')
  else if FileExists(ExpandConstant('{localappdata}\Programs\Python\Python310\python.exe')) then
    Result := ExpandConstant('{localappdata}\Programs\Python\Python310\python.exe');
end;

function InitializeSetup(): Boolean;
var
  PythonPath: String;
  ResultCode: Integer;
begin
  Result := True;
  
  // Verificar si Python está instalado
  PythonPath := GetPythonPath();
  
  if PythonPath = '' then
  begin
    if MsgBox('Python no fue detectado en este sistema.' + #13#10#13#10 +
              'La aplicación requiere Python 3.x para funcionar.' + #13#10#13#10 +
              '¿Desea continuar con la instalación de todos modos?' + #13#10 +
              '(Deberá instalar Python manualmente después)' + #13#10#13#10 +
              'Descargar Python desde: https://www.python.org/downloads/', 
              mbConfirmation, MB_YESNO) = IDNO then
    begin
      Result := False;
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  PrecargaContent: AnsiString;
  EjecutarContent: AnsiString;
  AppPath: String;
begin
  if CurStep = ssInstall then
  begin
    // Crear archivos ANTES de copiar los demás archivos
    AppPath := ExpandConstant('{app}');
    
    // Asegurarse de que el directorio existe
    if not DirExists(AppPath) then
      CreateDir(AppPath);
    
    // Crear archivo ejecutar.vbs con rutas correctas
    EjecutarContent :=
      'Dim oShell, oFSO, scriptPath' + #13#10 +
      'Set oShell = CreateObject("WScript.Shell")' + #13#10 +
      'Set oFSO = CreateObject("Scripting.FileSystemObject")' + #13#10 +
      '' + #13#10 +
      ''' Obtener la ruta donde está este script' + #13#10 +
      'scriptPath = oFSO.GetParentFolderName(WScript.ScriptFullName)' + #13#10 +
      '' + #13#10 +
      ''' Cambiar al directorio del script' + #13#10 +
      'oShell.CurrentDirectory = scriptPath' + #13#10 +
      '' + #13#10 +
      ''' Ejecutar precarga.hta desde la misma carpeta' + #13#10 +
      'oShell.Run "mshta.exe """ & scriptPath & "\precarga.hta""", 1, False';
    
    SaveStringToFile(AppPath + '\ejecutar.vbs', EjecutarContent, False);
    
    // Crear archivo precarga.hta con rutas correctas
    PrecargaContent := 
      '<html>' + #13#10 +
      '<head>' + #13#10 +
      '  <title>Cargando...</title>' + #13#10 +
      '  <HTA:APPLICATION' + #13#10 +
      '    APPLICATIONNAME="Areas Verdes Donihue"' + #13#10 +
      '    BORDER="none"' + #13#10 +
      '    BORDERSTYLE="none"' + #13#10 +
      '    CAPTION="no"' + #13#10 +
      '    SHOWINTASKBAR="yes"' + #13#10 +
      '    SINGLEINSTANCE="yes"' + #13#10 +
      '    WINDOWSTATE="normal"' + #13#10 +
      '    SCROLL="no"' + #13#10 +
      '  />' + #13#10 +
      '  <style>' + #13#10 +
      '    * { margin: 0; padding: 0; }' + #13#10 +
      '    body {' + #13#10 +
      '      background-color: #1a3a6b;' + #13#10 +
      '      width: 300px;' + #13#10 +
      '      height: 360px;' + #13#10 +
      '      text-align: center;' + #13#10 +
      '      overflow: hidden;' + #13#10 +
      '    }' + #13#10 +
      '    #contenedor {' + #13#10 +
      '      position: relative;' + #13#10 +
      '      width: 300px;' + #13#10 +
      '      height: 300px;' + #13#10 +
      '    }' + #13#10 +
      '    #logo-circular {' + #13#10 +
      '      width: 280px;' + #13#10 +
      '      height: 280px;' + #13#10 +
      '      display: block;' + #13#10 +
      '      margin: 10px auto 0 auto;' + #13#10 +
      '    }' + #13#10 +
      '    #spinner-wrap {' + #13#10 +
      '      display: none;' + #13#10 +
      '    }' + #13#10 +
      '    #cargando-texto {' + #13#10 +
      '      background-color: #1a3a6b;' + #13#10 +
      '      height: 50px;' + #13#10 +
      '      padding-top: 10px;' + #13#10 +
      '      color: white;' + #13#10 +
      '      font-size: 14px;' + #13#10 +
      '      font-family: Arial, sans-serif;' + #13#10 +
      '      font-weight: bold;' + #13#10 +
      '      letter-spacing: 1px;' + #13#10 +
      '      white-space: nowrap;' + #13#10 +
      '      overflow: hidden;' + #13#10 +
      '    }' + #13#10 +
      '  </style>' + #13#10 +
      '</head>' + #13#10 +
      '<body>' + #13#10 +
      '  <div id="contenedor">' + #13#10 +
      '    <img id="logo-circular" src="' + AppPath + '\assets\logoprecarga.png">' + #13#10 +
      '    <div id="spinner-wrap">' + #13#10 +
      '      <img src="' + AppPath + '\assets\spinner.gif.gif" width="40" height="40">' + #13#10 +
      '    </div>' + #13#10 +
      '  </div>' + #13#10 +
      '  <div id="cargando-texto">' + #13#10 +
      '    <img src="' + AppPath + '\assets\spinner.gif.gif" width="28" height="28" style="vertical-align:middle;margin-right:8px;">' + #13#10 +
      '    <span style="vertical-align:middle;" id="mensaje">Iniciando servidor...</span>' + #13#10 +
      '  </div>' + #13#10 +
      '' + #13#10 +
      '  <script language="VBScript">' + #13#10 +
      '    Dim intentos' + #13#10 +
      '    intentos = 0' + #13#10 +
      '' + #13#10 +
      '    Sub Window_OnLoad' + #13#10 +
      '      window.resizeTo 300, 360' + #13#10 +
      '      Dim sw, sh' + #13#10 +
      '      sw = screen.width' + #13#10 +
      '      sh = screen.height' + #13#10 +
      '      window.moveTo (sw - 300) / 2, (sh - 360) / 2' + #13#10 +
      '      window.setTimeout "IniciarServidor", 1000' + #13#10 +
      '    End Sub' + #13#10 +
      '' + #13#10 +
      '    Sub IniciarServidor' + #13#10 +
      '      Dim oShell, oExec, result, oFSO' + #13#10 +
      '      Set oShell = CreateObject("WScript.Shell")' + #13#10 +
      '      Set oFSO = CreateObject("Scripting.FileSystemObject")' + #13#10 +
      '      ' + #13#10 +
      '      '' Verificar si el puerto 8080 está en uso' + #13#10 +
      '      Set oExec = oShell.Exec("cmd /c netstat -ano | findstr :8080")' + #13#10 +
      '      result = oExec.StdOut.ReadAll' + #13#10 +
      '      ' + #13#10 +
      '      If InStr(result, ":8080") = 0 Then' + #13#10 +
      '        '' Puerto libre, iniciar servidor' + #13#10 +
      '        document.getElementById("mensaje").innerText = "Iniciando servidor..."' + #13#10 +
      '        ' + #13#10 +
      '        '' Cambiar al directorio de instalacion' + #13#10 +
      '        oShell.CurrentDirectory = "' + AppPath + '"' + #13#10 +
      '        ' + #13#10 +
      '        '' Intentar iniciar con pythonw (sin ventana)' + #13#10 +
      '        On Error Resume Next' + #13#10 +
      '        oShell.Run "pythonw servidor.py", 0, False' + #13#10 +
      '        If Err.Number <> 0 Then' + #13#10 +
      '          '' Si pythonw falla, intentar con python normal' + #13#10 +
      '          Err.Clear' + #13#10 +
      '          oShell.Run "python servidor.py", 0, False' + #13#10 +
      '        End If' + #13#10 +
      '        On Error Goto 0' + #13#10 +
      '        ' + #13#10 +
      '        '' Esperar y verificar que el servidor inicie' + #13#10 +
      '        window.setTimeout "VerificarServidor", 4000' + #13#10 +
      '      Else' + #13#10 +
      '        '' Servidor ya está corriendo' + #13#10 +
      '        document.getElementById("mensaje").innerText = "Conectando..."' + #13#10 +
      '        window.setTimeout "AbrirChrome", 500' + #13#10 +
      '      End If' + #13#10 +
      '    End Sub' + #13#10 +
      '' + #13#10 +
      '    Sub VerificarServidor' + #13#10 +
      '      Dim oShell, oExec, result' + #13#10 +
      '      Set oShell = CreateObject("WScript.Shell")' + #13#10 +
      '      Set oExec = oShell.Exec("cmd /c netstat -ano | findstr :8080")' + #13#10 +
      '      result = oExec.StdOut.ReadAll' + #13#10 +
      '      ' + #13#10 +
      '      If InStr(result, ":8080") > 0 Then' + #13#10 +
      '        '' Servidor iniciado correctamente' + #13#10 +
      '        document.getElementById("mensaje").innerText = "Abriendo aplicacion..."' + #13#10 +
      '        window.setTimeout "AbrirChrome", 500' + #13#10 +
      '      Else' + #13#10 +
      '        '' Servidor aun no inicia, reintentar' + #13#10 +
      '        intentos = intentos + 1' + #13#10 +
      '        If intentos < 15 Then' + #13#10 +
      '          document.getElementById("mensaje").innerText = "Esperando servidor (" & intentos & "/15)..."' + #13#10 +
      '          window.setTimeout "VerificarServidor", 1000' + #13#10 +
      '        Else' + #13#10 +
      '          document.getElementById("mensaje").innerText = "Error: Servidor no inicio"' + #13#10 +
      '          MsgBox "El servidor no pudo iniciar." & vbCrLf & vbCrLf & "Verifique que Python este instalado correctamente." & vbCrLf & "Ejecute diagnostico.bat para mas informacion.", vbCritical, "Error"' + #13#10 +
      '          window.close' + #13#10 +
      '        End If' + #13#10 +
      '      End If' + #13#10 +
      '    End Sub' + #13#10 +
      '' + #13#10 +
      '    Sub AbrirChrome' + #13#10 +
      '      Dim oShell, timestamp' + #13#10 +
      '      Set oShell = CreateObject("WScript.Shell")' + #13#10 +
      '      timestamp = Year(Now) & Month(Now) & Day(Now) & Hour(Now) & Minute(Now) & Second(Now)' + #13#10 +
      '      '' Abrir Chrome con flags para evitar cache' + #13#10 +
      '      oShell.Run "chrome.exe --disable-cache --disable-application-cache --disk-cache-size=1 http://localhost:8080?v=" & timestamp, 1, False' + #13#10 +
      '      window.setTimeout "CerrarVentana", 2000' + #13#10 +
      '    End Sub' + #13#10 +
      '' + #13#10 +
      '    Sub CerrarVentana' + #13#10 +
      '      window.close' + #13#10 +
      '    End Sub' + #13#10 +
      '  </script>' + #13#10 +
      '</body>' + #13#10 +
      '</html>';
    
    SaveStringToFile(AppPath + '\precarga.hta', PrecargaContent, False);
  end;
  
  if CurStep = ssPostInstall then
  begin
    // Crear archivo de información
    SaveStringToFile(ExpandConstant('{app}\LEEME.txt'), 
      'Áreas Verdes Doñihue - Versión 12.9' + #13#10 +
      '======================================' + #13#10#13#10 +
      'Desarrollado por: Josué Juan Muñoz Fuentealba' + #13#10 +
      'Año: 2026' + #13#10#13#10 +
      'REQUISITOS:' + #13#10 +
      '- Python 3.x instalado en el sistema' + #13#10 +
      '- Navegador Google Chrome' + #13#10#13#10 +
      'EJECUCIÓN:' + #13#10 +
      '- Haga doble clic en el icono "Áreas Verdes Doñihue" en el escritorio' + #13#10 +
      '- O ejecute desde el menú de inicio' + #13#10#13#10 +
      'SOLUCIÓN DE PROBLEMAS:' + #13#10 +
      '- Si no abre, verifique que Python está instalado' + #13#10 +
      '- Ejecute "python --version" en CMD para verificar' + #13#10 +
      '- Si Python no está en PATH, reinstale Python marcando "Add Python to PATH"' + #13#10#13#10 +
      'La aplicación iniciará automáticamente el servidor local y abrirá Chrome.' + #13#10,
      False);
  end;
end;
