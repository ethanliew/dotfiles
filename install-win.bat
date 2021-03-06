@echo off
:: ############################
:: # Install the dotfiles on Windows systems.
:: ############################

NET SESSION >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Not an admin, exiting.
    exit /B 1
)

setlocal EnableDelayedExpansion

if exist "%HOME%" (
	set homeDir=%HOME%
) else (
	if exist "%HOMEDRIVE%%HOMEPATH%" (
		set homeDir=%HOMEDRIVE%%HOMEPATH%
	) else (
		set homeDir=%USERPROFILE%
	)
)

IF %homeDir:~-1%==\ SET homeDir=%homeDir:~0,-1%

set dotfilesDir=%~dp0
set backupDir=%homeDir%\dotfiles_backup
set dotfiles=bashrc bash_profile config minttyrc zshenv puppet-lint.rc

:: add registry key for init.bat
if exist "%CLINK_DIR%" (
    reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_EXPAND_SZ /d "%dotfilesDir%init.bat&\"%%CLINK_DIR%%\clink\" inject --profile ~\clink" /f
) else (
    reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d "%dotfilesDir%init.bat" /f
)

for %%A in (%dotfiles%) DO (
    call:createSymLink "%dotfilesDir%%%A" "%homeDir%\.%%A" "%backupDir%" true
)

call:createSymLink "%dotfilesDir%config\readline\inputrc" "%homeDir%\.inputrc" "%backupDir%" true

set sublimeDir=%APPDATA%\Sublime Text 3\Packages
set backupDir=%homeDir%\dotfiles_backup\sublime

if exist "%sublimeDir%" (
    call:createSymLink "%dotfilesDir%sublime\User" "%sublimeDir%\User" "%backupDir%" false
    call:createSymLink "%dotfilesDir%sublime\User (OS Settings)" "%sublimeDir%\User (OS Settings)" "%backupDir%" false
)

set vsCodeDir=%APPDATA%\Code
set backupDir=%homeDir%\dotfiles_backup\code

if exist "%vsCodeDir%" (
    call:createSymLink "%dotfilesDir%vscode\User" "%vsCodeDir%\User" "%backupDir%" false
)

set backupDir=%homeDir%\dotfiles_backup\atom
set atomfiles=config.cson init.coffee keymap.cson snippets.cson styles.less

if not exist "%homeDir%\.atom" (
    mkdir "%homeDir%\.atom"
)

for %%A in (%atomfiles%) DO (
    call:createSymLink "%dotfilesDir%\atom\%%A" "%homeDir%\.atom\%%A" "%backupDir%" false
)

set backupDir=%homeDir%\dotfiles_backup\bin
set binDir=%homeDir%\bin
set binfiles=create-eclipse-shortcuts.cmd create-eclipse-shortcuts.ps1 stree.cmd update-everything.cmd

if not exist "%binDir%" (
    mkdir "%binDir%"
)

for %%A in (%binfiles%) DO (
    call:createSymLink "%dotfilesDir%\bin\%%A" "%binDir%\%%A" "%backupDir%" false
)

PowerShell.exe -Command  "& Set-ExecutionPolicy RemoteSigned -Force"
PowerShell.exe -ExecutionPolicy RemoteSigned -File install-win.ps1 %dotfilesDir%Microsoft.PowerShell_profile.ps1

goto:EOF

::function
:createSymLink - target linkName backupDirectory hideLink
    set linkExists="0"
    if exist "%~2" (
        set Z=&& for %%A in ("%~2") do set Z=%%~aA
        if "!Z:~8,1!" == "l" (
            set linkExists="1"
        ) else (
            if not exist "%~3" (
                mkdir "%~3"
            )
            echo Moving existing %2 to %3
            move "%~2" "%~3"
        )
    )

    if !linkExists! == "0" (
        if exist "%~1\" (
            mklink /d "%~2" "%~1"
        ) else (
            mklink "%~2" "%~1"
        )
        if %4 == "true" (
        	attrib /L "%~2" +h
        )
    ) else (
        echo Not replacing existing link %2
    )

goto:EOF
