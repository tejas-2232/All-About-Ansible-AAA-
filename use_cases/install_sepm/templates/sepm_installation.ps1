Start-Process -FilePath 'C:\SEPM-Win\setup.exe' -Verb runAs -Wait

Start-Sleep -s 72

$serviceName = "Symantec Endpoint Protection"
$software = "Symantec Endpoint Protection version 14.0.1032.0200 - English";
