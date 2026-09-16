# Importar el módulo LocalAccounts
Import-Module Microsoft.PowerShell.LocalAccounts

# Nombre del usuario
$usuario = "gvuser"

# Verificar si el usuario existe
$usuarioExiste = Get-LocalUser -Name $usuario -ErrorAction SilentlyContinue

# Si el usuario no existe, lo crea
if ($null -eq $usuarioExiste) {
    Write-Host "El usuario $usuario no existe. Creando el usuario..."
    
    # Crear el usuario con la clave
    $clave = ConvertTo-SecureString "Grup0V@zqu3z!" -AsPlainText -Force
    New-LocalUser -Name $usuario -Password $clave -FullName $usuario -Description "Usuario administrador creado por absolute"
    
    Write-Host "Usuario $usuario creado exitosamente."
} else {
    Write-Host "El usuario $usuario ya existe. Actualizando configuración..."
    
    # Cambiar la contrasena
    Set-LocalUser -Name $usuario -Password (ConvertTo-SecureString "Grup0V@zqu3z!" -AsPlainText -Force)
    
}

#habilitar usuario
Enable-LocalUser -Name $usuario
#agregar usuario como administrador
$grupoAdminEN = "Administrators"
$grupoAdminES = "Administradores"

# Obtener todos los grupos locales
$grupos = Get-LocalGroup | Select-Object -ExpandProperty Name

# Verificar si existe "Administrators" o "Administradores" y agrega "gvuser" al respectivo grupo
if ($grupos -eq $grupoAdminEN) {
    Write-Output "El grupo de administradores es 'Administrators'."
    $EsAdmin = Get-LocalGroupMember -Group "Administrators" | Where-Object { $_.Name -like "*$usuario" }
    if (-not $EsAdmin) {
        Write-Host "El usuario '$usuario' no es administrador. Asignando permisos..."
        Add-LocalGroupMember -Group "Administrators" -Member "$usuario"
    }
    # Remove todos os outros usuários do grupo
    Get-LocalGroupMember -Group "Administrators" | Where-Object { $_.Name -notlike "*$usuario" } | ForEach-Object {
        Write-Host "Removiendo: $($_.Name)"
        Remove-LocalGroupMember -Group "Administrators" -Member $_.Name
        Write-Host "Agregando a Users: $($_.Name)"
        Add-LocalGroupMember -Group "Users" -Member $_.Name
    }

} elseif ($grupos -eq $grupoAdminES) {
    Write-Output "El grupo de administradores es 'Administradores'."
    $EsAdmin = Get-LocalGroupMember -Group "Administradores" | Where-Object { $_.Name -like "*$usuario" }
    if (-not $EsAdmin) {
        Write-Host "El usuario '$usuario' no es administrador. Asignando permisos..."
        Add-LocalGroupMember -Group "Administradores" -Member "$usuario"
    }
    # Remove todos os outros usuários do grupo
    Get-LocalGroupMember -Group "Administradores" | Where-Object { $_.Name -notlike "*$usuario" } | ForEach-Object {
        Write-Host "Removiendo: $($_.Name)"
        Remove-LocalGroupMember -Group "Administradores" -Member $_.Name
        Write-Host "Agregando a Usuarios: $($_.Name)"
        Add-LocalGroupMember -Group "Usuarios" -Member $_.Name
    }

} else {
    Write-Output "No se encontró un grupo de administradores estándar."
}

# Definir la función para generar una contrasena aleatoria
function Generar-contrasenaAleatoria {
    $CaracteresPermitidos = 'ABCDEFGHJKLMNOPQRSTUVWXYZabcdefghijkmnxyz0123456789!@#$%&*+.?'
    $Longitud = 12

    # Agregar al menos 1 mayúscula
    $contrasena = -join ($CaracteresPermitidos.ToCharArray() | Where-Object { $_ -match '[A-Z]' } | Get-Random)

    # Agregar al menos 1 número
    $contrasena += -join ($CaracteresPermitidos.ToCharArray() | Where-Object { $_ -match '[0-9]' } | Get-Random)

    # Agregar al menos 1 carácter especial
    $contrasena += -join ($CaracteresPermitidos.ToCharArray() | Where-Object { $_ -match '[!@#$%*+.]' } | Get-Random)

    # Generar el resto de la contrasena
    for ($i = 0; $i -lt ($Longitud - 3); $i++) {
        $contrasena += $CaracteresPermitidos[(Get-Random -Minimum 0 -Maximum $CaracteresPermitidos.Length)]
    }

    return $contrasena
}

# Generar una contrasena aleatoria
$contrasenaGenerada = Generar-contrasenaAleatoria

# Convertir la contrasena en SecureString
$ContraSecureString = ConvertTo-SecureString $contrasenaGenerada -AsPlainText -Force

# Cambiar la contrasena del usuario local "gvuser"
try {
    Set-LocalUser -Name $usuario -Password $ContraSecureString
    Write-Host "La contrasena se cambió exitosamente para el usuario '$usuario'."
    Write-Host "La nueva contrasena es: $contrasenaGenerada"
} catch {
    Write-Host "Error al cambiar la contrasena: $_"
}
# Output model and serial to CDF parser
try {
  $LibraryPath = $env:ProgramData + "\CTES\Components\ANS\CDFClientLibrary.dll"
  [Reflection.Assembly]::LoadFile($LibraryPath)
  [CDFClientLibrary.CDFParser]::addCDF("AdminPass", $contrasenaGenerada, "text")
  [CDFClientLibrary.CDFParser]::completeCDFProcessing()
  }

catch [Exception] {   
  Write-Host $_.Exception.Message 
  Write-Host $_.InvocationInfo.PositionMessage
  }

