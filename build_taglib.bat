SETLOCAL
echo "Building taglib"
set TAGLIB_PATH=taglib-1.11.1
SET VALRETURN=0

if %MACHINE_X86% (
  set PLATFORM=Win32
  set COMPILERPROJECT="Visual Studio 14 2015"
) else (
  set PLATFORM=x64
  set COMPILERPROJECT="Visual Studio 14 2015 Win64"
)

if %CONFIG_RELEASE% (
  set CONFIG=RelWithDebInfo
) else (
  set CONFIG=Debug
)

set ZLIBNAME=zlibwapi.lib

if %STATIC_LIBS% (
    set DYNAMIC=OFF
) else (
    set DYNAMIC=ON
)

cd build\%TAGLIB_PATH%
REM Re-generate solution files.
rd /S /Q %PLATFORM%
mkdir %PLATFORM%
cd %PLATFORM%
REM NOTE(pegasus): generated solution with

"%CMAKEDIR%\cmake" .. -G %COMPILERPROJECT% -DBUILD_SHARED_LIBS=%DYNAMIC% -DCMAKE_SUPPRESS_REGENERATION=1 -DZLIB_INCLUDE_DIR=%INCLUDE_DIR% -DZLIB_LIBRARY=%LIB_DIR%\%ZLIBNAME% -DCMAKE_PREFIX_PATH=%ROOT_DIR%\Qt-%QT_VERSION%\lib\cmake -DCMAKE_INSTALL_PREFIX=%ROOT_DIR% -DCMAKE_INSTALL_INCLUDEDIR=%INCLUDE_DIR%
IF ERRORLEVEL 1 (
    SET VALRETURN=1
	goto END
)
 
"%CMAKEDIR%\cmake" --build . --config %CONFIG% --clean-first 
IF ERRORLEVEL 1 (
    SET VALRETURN=1
	goto END
)

"%CMAKEDIR%\cmake" --build . --target install 
IF ERRORLEVEL 1 (
    SET VALRETURN=1
    goto END
)

copy tag.dir\RelWithDebInfo\tag.pdb %LIB_DIR%

:END
cd %ROOT_DIR%
REM the GOTO command resets the errorlevel and the endlocal resets the local environment,
REM so I have to use this workaround
ENDLOCAL & SET VALRETURN=%VALRETURN%
exit /b %VALRETURN%
