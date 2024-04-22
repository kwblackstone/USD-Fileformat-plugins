@echo off
SETLOCAL ENABLEEXTENSIONS
SETLOCAL EnableDelayedExpansion

:: Set the USD version and OS type (assumed to be windows for this script)
set USD_VERSION=2308
set OS_TYPE=windows
set USD_LOCATION=%CD%\usd_location
set CURRENT_INSTALL=%CD%\bin

:: Checkout the latest code (assuming the script is run from within a git repo directory)
git pull origin main
IF ERRORLEVEL 1 GOTO error

:: Install cmake and unzip if not already installed (manual step, uncomment if needed)
:: choco install cmake
:: choco install unzip

IF EXIST usd_location (
    rmdir /s /q usd_location
)

:: Delete the zip file if it exists
IF EXIST usd-%USD_VERSION%-%OS_TYPE%-latest.zip (
    del usd-%USD_VERSION%-%OS_TYPE%-latest.zip
)

:: Download the correct USD zip file from GitHub
echo gh release download USD-%USD_VERSION%-Artifacts -p "usd-%USD_VERSION%-%OS_TYPE%-latest.zip" --repo darkrock76/plugin_build
gh release download USD-%USD_VERSION%-Artifacts -p "usd-%USD_VERSION%-%OS_TYPE%-latest.zip" --repo darkrock76/plugin_build
IF ERRORLEVEL 1 GOTO error

:: Unzip the artifact
echo unzip -q usd-%USD_VERSION%-%OS_TYPE%-latest.zip -d %USD_LOCATION%
unzip -q usd-%USD_VERSION%-%OS_TYPE%-latest.zip -d %USD_LOCATION%
IF ERRORLEVEL 1 GOTO error

:: Replace occurrences in the file
SET CD_FORWARD=%CD:\=/%
powershell -Command "(Get-Content '%USD_LOCATION%/cmake/pxrTargets.cmake') | ForEach-Object { [regex]::Replace($_, 'USD_LOCATION', '%CD_FORWARD%/usd_location') } | ForEach-Object { [regex]::Replace($_, 'PYTHON_LOCATION', 'C:/Users/Keith/AppData/Local/Programs/Python/Python310') } | Set-Content '%USD_LOCATION%/cmake/pxrTargets.cmake'"
powershell -Command "(Get-Content '%USD_LOCATION%/lib/cmake/OpenImageIO/OpenImageIOConfig.cmake') | ForEach-Object { [regex]::Replace($_, 'USD_LOCATION', '%CD_FORWARD%/usd_location') } | ForEach-Object { [regex]::Replace($_, 'PYTHON_LOCATION', 'C:/Users/Keith/AppData/Local/Programs/Python/Python310') } | Set-Content '%USD_LOCATION%/lib/cmake/OpenImageIO/OpenImageIOConfig.cmake'"
powershell -Command "(Get-Content '%USD_LOCATION%/lib/cmake/OpenImageIO/OpenImageIOTargets.cmake') | ForEach-Object { [regex]::Replace($_, 'USD_LOCATION', '%CD_FORWARD%/usd_location') } | ForEach-Object { [regex]::Replace($_, 'PYTHON_LOCATION', 'C:/Users/Keith/AppData/Local/Programs/Python/Python310') } | Set-Content '%USD_LOCATION%/lib/cmake/OpenImageIO/OpenImageIOTargets.cmake'"

IF EXIST build (
    rmdir /s /q build
)

:: Set environment variables
set PATH=%PYTHON3_PATH%;%USD_LOCATION%\bin;%USD_LOCATION%\lib;%USD_LOCATION%\plugin\usd;%CURRENT_INSTALL%\bin;%CURRENT_INSTALL%\plugin\usd;%PATH%
set PXR_PLUGINPATH_NAME=%CURRENT_INSTALL%\plugin\usd;%USD_LOCATION%\plugin\usd
set PYTHONPATH=%USD_LOCATION%\lib\python;%PYTHONPATH%

:: Configure with CMake
echo cmake -S . -B build -DCMAKE_INSTALL_PREFIX=%CURRENT_INSTALL% -Dpxr_ROOT="%USD_LOCATION%" -DUSD_FILEFORMATS_ENABLE_FBX=OFF -DUSD_FILEFORMATS_BUILD_TESTS=ON -DPython3_LIBRARY="C:\Users\Keith\AppData\Local\Programs\Python\Python310\libs\python310.lib" -DPython3_INCLUDE_DIR="C:\Users\Keith\AppData\Local\Programs\Python\Python310\include" -DPython3_VERSION="3.10.11"
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=%CURRENT_INSTALL% -Dpxr_ROOT="%USD_LOCATION%" -DUSD_FILEFORMATS_ENABLE_FBX=OFF -DUSD_FILEFORMATS_BUILD_TESTS=ON -DPython3_LIBRARY="C:\Users\Keith\AppData\Local\Programs\Python\Python310\libs\python310.lib" -DPython3_INCLUDE_DIR="C:\Users\Keith\AppData\Local\Programs\Python\Python310\include" -DPython3_VERSION="3.10.11"
IF ERRORLEVEL 1 GOTO error

:: Build
echo cmake --build build --config Release
cmake --build build --config Release
IF ERRORLEVEL 1 GOTO error

:: Install
echo cmake --install build --config Release
cmake --install build --config Release
IF ERRORLEVEL 1 GOTO error

:: Install test requirements
echo pip install -r scripts/requirements.txt
%PYTHON3_PATH%/scripts/pip install -r scripts/requirements.txt
IF ERRORLEVEL 1 GOTO error

:: Run tests
echo %PYTHON3_PATH%/scripts/pytest ./test/test.py
%PYTHON3_PATH%/scripts/pytest ./test/test.py
IF ERRORLEVEL 1 GOTO error

GOTO end

:error
echo.
echo ERROR: An error occurred during execution.
exit /b 1

:end
ENDLOCAL
