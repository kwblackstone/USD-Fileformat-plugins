:: Set environment variables
set USD_LOCATION=%CD%\usd_location
set CURRENT_INSTALL=%CD%\bin
set PATH=C:\Users\Keith\AppData\Local\Programs\Python\Python310;%USD_LOCATION%\bin;%USD_LOCATION%\lib;%USD_LOCATION%\plugin\usd;%CURRENT_INSTALL%\bin;%CURRENT_INSTALL%\plugin\usd;%PATH%
set PXR_PLUGINPATH_NAME=%CURRENT_INSTALL%\plugin\usd;%USD_LOCATION%\plugin\usd
set PYTHONPATH=%USD_LOCATION%\lib\python;%PYTHONPATH%

:: Install test requirements
echo pip install -r scripts/requirements.txt
%PYTHON3_PATH%/scripts/pip install -r scripts/requirements.txt
IF ERRORLEVEL 1 GOTO error

:: Run tests
echo pytest ./test/test.py
:: usdrecord C:\Git\darkrock76\plugin_build\test\assets\gltf\cube-colors.glb C:\Git\darkrock76\plugin_build\test\output\cube-colors.jpg
%PYTHON3_PATH%/scripts/pytest ./test/test.py
IF ERRORLEVEL 1 GOTO error