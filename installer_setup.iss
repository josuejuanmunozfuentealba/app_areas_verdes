; Script de Inno Setup para Áreas Verdes Doñihue
; Generado para crear instalador de Windows

#define MyAppName "Áreas Verdes Doñihue"
#define MyAppVersion "12.11"
#define MyAppPublisher "Josué Juan Muñoz Fuentealba"
#define MyAppExeName "ejecutar_sin_python.bat"
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
Source: "ejecutar_sin_python.bat"; DestDir: "{app}"; Flags: ignoreversion
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
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    SaveStringToFile(ExpandConstant('{app}\LEEME.txt'),
      'Áreas Verdes Doñihue - Versión 12.11' + #13#10 +
      '======================================' + #13#10#13#10 +
      'Esta versión se ejecuta directamente desde la carpeta instalada.' + #13#10 +
      'No requiere Python ni servidor local.' + #13#10,
      False);
  end;
end;

