# Local Admin User Creation - Runbook

## Overview
PowerShell script que crea/actualiza usuario administrador local en equipos Windows via Absolute Platform.

## Purpose
- Usuario admin local necesario para tareas de administración (instalar, desinstalar, configurar software)
- Contraseña temporal y aleatoria que expira automáticamente cada 30 días
- Seguridad: solo IT (acceso a Absolute) puede ver la contraseña

## How It Works

### Process
1. Verifica si usuario "gvuser" existe
2. Si NO existe → crear con contraseña inicial
3. Si EXISTE → regenerar contraseña aleatoria nueva
4. Agregar usuario al grupo Administrators (maneja EN/ES)
5. Guardar contraseña en CDF de Absolute (acceso IT only)
6. Contraseña expira automáticamente en 30 días

### Password Generation
- Longitud: 12 caracteres
- Requisitos: mínimo 1 mayúscula, 1 número, 1 carácter especial
- Caracteres permitidos: A-Z, a-z, 0-9, !@#$%&*+.?

## Execution

**Platform**: Absolute  
**Frequency**: On-demand, múltiples veces por día  
**Who Runs It**: IT Support (via Absolute console)  
**Where**: Seleccionar serial del equipo en Absolute → elegir script

## Security Notes
- Primera contraseña (hardcodeada) solo para creación inicial del usuario
- Todas las contraseñas posteriores son aleatorias
- **Contraseña NO es visible** para usuarios finales (solo IT en Absolute)
- Usuario "gvuser" es cuenta de administrador local compartida
- Expiry automático cada 30 días (Windows policy)

## Logs & Audit
- Script se ejecuta via Absolute → auditoría en Absolute console
- Quién ejecutó, cuándo, en qué equipo, resultado
- Contraseña guardada en CDF (Absolute Data Format)

## Troubleshooting

| Problema | Causa | Solución |
|----------|-------|----------|
| Script falla | Antivirus bloqueando | Whitelistar script en Windows Defender/Netskope |
| Usuario no es admin | Grupo no existe | Verificar grupo Administrators vs Administradores (idioma) |
| Contraseña no funciona | Expiró (30 días) | Re-lanzar script desde Absolute |
| CDF error | Librería no disponible | Verificar ruta `C:\ProgramData\CTES\Components\ANS\CDFClientLibrary.dll` |

## Related Scripts
- None currently

## Maintenance
- Review: Quarterly
- Last Updated: September 2026
- Owner: Eduardo Espinola (E-Tech Internal Support Analyst)
