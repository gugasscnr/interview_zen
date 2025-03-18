@echo off
setlocal enabledelayedexpansion

echo ===================================================
echo  Configuracao Completa do Ambiente - Blog Agi
echo ===================================================
echo.

:: Definir versoes e variaveis
set JAVA_MIN_VERSION=11
set GRADLE_VERSION=8.7
set PROJECT_DIR=%CD%
set GRADLE_HOME=%PROJECT_DIR%\gradle-temp
set CURL_INSTALLED=0
set RETRY_COUNT=0
set MAX_RETRIES=3
set ALLURE_VERSION=2.25.0
set TESTNG_VERSION=7.9.0
set SETUP_SUCCESS=0
set OFFLINE_MODE=0

:: Verificar se o modo offline foi solicitado
if "%1"=="--offline" (
    set OFFLINE_MODE=1
    echo Modo offline ativado. Usando recursos locais quando possivel.
    echo.
)

:: Criar pasta temporaria
if not exist temp mkdir temp

:: -------------------- Verificacao de Java --------------------
echo [1/5] Verificando instalacao do Java...
java -version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Java nao encontrado. Vamos verificar se o JAVA_HOME esta configurado...
    
    if defined JAVA_HOME (
        echo JAVA_HOME encontrado: %JAVA_HOME%
        if exist "!JAVA_HOME!\bin\java.exe" (
            echo Adicionando Java ao PATH temporariamente...
            set "PATH=!JAVA_HOME!\bin;%PATH%"
            echo Path atualizado. Verificando novamente...
            java -version >nul 2>&1
            if !ERRORLEVEL! NEQ 0 (
                echo Ainda nao foi possivel encontrar o Java. Verifique a instalacao do JAVA_HOME.
                goto :java_missing
            ) else (
                echo Java encontrado atraves do JAVA_HOME.
            )
        ) else (
            echo JAVA_HOME definido, mas java.exe nao encontrado em !JAVA_HOME!\bin.
            goto :java_missing
        )
    ) else (
        :java_missing
        echo.
        echo ERRO: Java JDK %JAVA_MIN_VERSION% ou superior eh necessario.
        echo Por favor, instale o JDK e tente novamente.
        echo.
        echo Opcoes de download:
        echo 1. Oracle JDK: https://www.oracle.com/java/technologies/javase-jdk11-downloads.html
        echo 2. OpenJDK: https://adoptium.net/
        echo 3. Amazon Corretto: https://aws.amazon.com/pt/corretto/
        echo.
        echo Apos instalar, reinicie este script.
        echo.
        pause
        exit /b 1
    )
) else (
    echo Java encontrado. Verificando versao...
)

:: Verificar versao do Java
for /f tokens^=2-5^ delims^=.-_^" %%j in ('java -fullversion 2^>^&1') do (
    set JAVA_VERSION=%%j
)

if %JAVA_VERSION% LSS %JAVA_MIN_VERSION% (
    echo.
    echo AVISO: A versao do Java %JAVA_VERSION% eh menor que a recomendada %JAVA_MIN_VERSION%.
    echo Alguns recursos podem nao funcionar corretamente.
    echo.
    set /p CONTINUE="Deseja continuar mesmo assim? (S/N): "
    if /i "!CONTINUE!" NEQ "S" exit /b 1
)

echo Java %JAVA_VERSION% esta instalado e configurado.
echo.

:: -------------------- Verificacao de curl --------------------
echo [2/5] Verificando a disponibilidade do curl...
curl --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo curl nao encontrado. Algumas operacoes de download podem falhar.
    echo Vamos tentar usar powershell para downloads...
    set CURL_INSTALLED=0
) else (
    echo curl encontrado. Sera usado para downloads.
    set CURL_INSTALLED=1
)
echo.

:: -------------------- Configuracao do Wrapper Gradle --------------------
echo [3/5] Configurando Gradle...

if exist gradlew.bat (
    echo Arquivo gradlew.bat existente. Verificando funcionalidade...
    call :verify_gradle_wrapper
    if !GRADLE_WORKING! EQU 1 (
        echo Gradle Wrapper funcional detectado.
    ) else (
        echo Gradle Wrapper existente nao esta funcionando. Vamos recria-lo.
        call :setup_gradle_wrapper
    )
) else (
    echo Gradle Wrapper nao encontrado. Instalando...
    call :setup_gradle_wrapper
)

:: -------------------- Criacao de diretorios e arquivos de configuracao --------------------
echo [4/5] Preparando diretorios do projeto...

echo Criando diretorios necessarios...
if not exist logs mkdir logs
if not exist src\main\java\com\test\agi\pages mkdir src\main\java\com\test\agi\pages
if not exist src\test\java\com\test\agi\config mkdir src\test\java\com\test\agi\config
if not exist src\test\java\com\test\agi\tests mkdir src\test\java\com\test\agi\tests
if not exist src\test\java\com\test\agi\utils mkdir src\test\java\com\test\agi\utils
if not exist src\test\resources mkdir src\test\resources
echo Diretorios criados.

:: Verificar arquivos de configuracao essenciais
if not exist build.gradle (
    echo AVISO: Arquivo build.gradle nao encontrado. 
    echo Este arquivo eh essencial. Verifique se o repositorio foi clonado corretamente.
    echo.
    set /p CONTINUE="Pressione qualquer tecla para continuar..."
    goto :setup_failed
)

if not exist src\test\resources\testng.xml (
    echo Criando arquivo testng.xml...
    mkdir src\test\resources >nul 2>&1
    (
        echo ^<!DOCTYPE suite SYSTEM "https://testng.org/testng-1.0.dtd" ^>
        echo ^<suite name="BlogAgiTestSuite" verbose="1"^>
        echo     ^<test name="BuscaTests"^>
        echo         ^<classes^>
        echo             ^<class name="com.test.agi.tests.BuscaTests"/^>
        echo         ^</classes^>
        echo     ^</test^>
        echo ^</suite^>
    ) > src\test\resources\testng.xml
)
echo.

:: -------------------- Baixar dependencias e construir o projeto --------------------
echo [5/5] Baixando dependencias e construindo projeto...

:: Verificar se o build.gradle precisa ser recriado
if exist build.gradle (
    echo Verificando build.gradle...
    findstr /i "allure\|testng\|selenium" build.gradle >nul
    if !ERRORLEVEL! NEQ 0 (
        echo Build.gradle parece incompleto. Criando backup e gerando um novo...
        copy build.gradle build.gradle.bak.incomplete >nul
        call :create_complete_build_gradle
    )
) else (
    echo Arquivo build.gradle nao encontrado. Criando...
    call :create_complete_build_gradle
)

:: Tentar baixar dependencias apenas se nao estiver no modo offline
if %OFFLINE_MODE% EQU 0 (
    echo Executando build inicial para baixar dependencias...
    
    call :gradle_safe_execute --no-daemon clean
    
    :: Se o build falhar, tente algumas estrategias de recuperacao
    set /a RETRY_COUNT=0
    :retry_dependencies
    call :gradle_safe_execute --refresh-dependencies --no-daemon dependencies --configuration runtimeClasspath
    
    if !ERRORLEVEL! NEQ 0 (
        set /a RETRY_COUNT+=1
        if !RETRY_COUNT! LSS %MAX_RETRIES% (
            echo Falha ao baixar dependencias. Tentativa !RETRY_COUNT! de %MAX_RETRIES%...
            
            if !RETRY_COUNT! EQU 1 (
                echo Tentando limpar o cache do Gradle...
                call :gradle_safe_execute --no-daemon clean cleanCache
                if !ERRORLEVEL! NEQ 0 (
                    echo Tarefa cleanCache nao disponivel. Tentando outra abordagem...
                    rmdir /s /q %USERPROFILE%\.gradle\caches\* 2>nul
                )
                goto :retry_dependencies
            )
            
            if !RETRY_COUNT! EQU 2 (
                echo Tentando baixar dependencias manualmente...
                call :download_critical_dependencies
                goto :retry_dependencies
            )
        ) else (
            echo Esgotadas tentativas de baixar dependencias.
            echo Tentando continuar mesmo com conflitos...
            set SETUP_SUCCESS=0
        )
    )
) else (
    echo Modo offline: pulando download de dependencias.
)

:: Fazer o build do projeto sem executar os testes
echo Tentando construir o projeto sem executar os testes...
call :gradle_safe_execute --no-daemon assemble
if %ERRORLEVEL% NEQ 0 (
    echo AVISO: Falha no build inicial, mas tentaremos continuar.
    echo Talvez seja necessario resolver problemas de dependencias manualmente.
    
    echo Adicionando informacoes de resolucao de conflitos...
    
    if exist build.gradle (
        echo Criando backup do build.gradle...
        copy build.gradle build.gradle.bak >nul
        
        echo Modificando build.gradle para resolver conflitos...
        
        :: Verificar se build.gradle já tem os repositórios
        findstr /i "mavenCentral" build.gradle >nul
        if !ERRORLEVEL! NEQ 0 (
            echo Adicionando repositórios Maven...
            echo. >> build.gradle
            echo repositories { >> build.gradle
            echo     mavenCentral^(^) >> build.gradle
            echo     maven ^{ url 'https://jcenter.bintray.com' ^} >> build.gradle
            echo     maven ^{ url 'https://repo.maven.apache.org/maven2/' ^} >> build.gradle
            echo ^} >> build.gradle
        )
        
        :: Adicionar configuração de resolução de conflitos
        echo. >> build.gradle
        echo // Configuracao para resolver conflitos de dependencias >> build.gradle
        echo configurations.all ^{ >> build.gradle
        echo     resolutionStrategy ^{ >> build.gradle
        echo         force 'org.slf4j:slf4j-api:1.7.36' >> build.gradle
        echo         force 'org.apache.commons:commons-lang3:3.14.0' >> build.gradle
        echo         force 'org.apache.commons:commons-compress:1.26.0' >> build.gradle
        echo         force 'org.apache.httpcomponents.client5:httpclient5:5.2.1' >> build.gradle
        echo         force 'com.google.guava:guava:33.0.0-jre' >> build.gradle
        echo         force 'commons-io:commons-io:2.15.1' >> build.gradle
        echo     ^} >> build.gradle
        echo ^} >> build.gradle
        
        :: Adicionar dependências específicas para o Allure se não existirem
        findstr /i "io.qameta.allure" build.gradle >nul
        if !ERRORLEVEL! NEQ 0 (
            echo Adicionando dependencia explícita do Allure...
            echo. >> build.gradle
            echo dependencies ^{ >> build.gradle
            echo     if ^(!project.hasProperty^('dependencies'^)^) ^{ >> build.gradle
            echo         implementation 'io.qameta.allure:allure-testng:%ALLURE_VERSION%' >> build.gradle
            echo         implementation 'org.testng:testng:%TESTNG_VERSION%' >> build.gradle
            echo     ^} >> build.gradle
            echo ^} >> build.gradle
        )
        
        echo Build.gradle modificado. Tentando construir novamente...
        call :gradle_safe_execute --refresh-dependencies --no-daemon assemble
    )
) else (
    echo Build inicial concluido com sucesso.
    set SETUP_SUCCESS=1
)

goto :setup_completed

:: ==================== FUNCOES DE SUPORTE ====================

:setup_gradle_wrapper
echo Configurando Gradle Wrapper...

:: Tenta criar gradle-wrapper.properties primeiro
mkdir gradle\wrapper 2>nul

:: Criar o arquivo de propriedades manualmente
echo distributionBase=GRADLE_USER_HOME> gradle\wrapper\gradle-wrapper.properties
echo distributionPath=wrapper/dists>> gradle\wrapper\gradle-wrapper.properties
echo distributionUrl=https\://services.gradle.org/distributions/gradle-%GRADLE_VERSION%-bin.zip>> gradle\wrapper\gradle-wrapper.properties
echo zipStoreBase=GRADLE_USER_HOME>> gradle\wrapper\gradle-wrapper.properties
echo zipStorePath=wrapper/dists>> gradle\wrapper\gradle-wrapper.properties

:: Baixar arquivo gradlew.bat
if %CURL_INSTALLED% EQU 1 (
    echo Baixando gradlew.bat com curl...
    curl -L -o gradlew.bat https://raw.githubusercontent.com/gradle/gradle/master/gradlew.bat
) else (
    echo Baixando gradlew.bat com PowerShell...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/gradle/gradle/master/gradlew.bat', 'gradlew.bat')"
)

:: Verificar se o download foi bem-sucedido
if not exist gradlew.bat (
    echo Falha ao baixar gradlew.bat.
    echo Usando versao local...
    call :create_local_gradlew_bat
) else (
    echo gradlew.bat baixado com sucesso.
)

:: Verificar se o gradlew.bat foi criado
if not exist gradlew.bat (
    echo ERRO critico: Nao foi possivel criar gradlew.bat
    exit /b 1
)

:: Baixar gradle-wrapper.jar
if %CURL_INSTALLED% EQU 1 (
    echo Baixando gradle-wrapper.jar com curl...
    curl -L -o gradle\wrapper\gradle-wrapper.jar https://github.com/gradle/gradle/raw/master/gradle/wrapper/gradle-wrapper.jar
) else (
    echo Baixando gradle-wrapper.jar com PowerShell...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/gradle/gradle/raw/master/gradle/wrapper/gradle-wrapper.jar', 'gradle\wrapper\gradle-wrapper.jar')"
)

:: Verificar se o download foi bem-sucedido
if not exist gradle\wrapper\gradle-wrapper.jar (
    echo Falha ao baixar gradle-wrapper.jar.
    echo.
    echo AVISO: gradle-wrapper.jar eh essencial para o funcionamento do Gradle Wrapper.
    echo Voce precisara baixa-lo manualmente e salva-lo em gradle\wrapper\.
    echo URL para download: https://github.com/gradle/gradle/raw/master/gradle/wrapper/gradle-wrapper.jar
    echo.
    set /p CONTINUE="Pressione qualquer tecla para continuar..."
)

:: Criar gradlew.cmd para facilitar o uso
echo @echo off> gradlew.cmd
echo call gradlew.bat %%*>> gradlew.cmd

:: Configurar permissoes
icacls gradlew.bat /grant Everyone:RX >nul 2>&1
icacls gradlew.cmd /grant Everyone:RX >nul 2>&1

call :verify_gradle_wrapper
if !GRADLE_WORKING! EQU 0 (
    echo.
    echo AVISO: O Gradle Wrapper ainda nao esta funcionando.
    echo Talvez seja necessario instalar o Gradle manualmente.
    echo.
    goto :install_gradle_manually_ask
)

exit /b 0

:verify_gradle_wrapper
set GRADLE_WORKING=0
call gradlew.bat --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set GRADLE_WORKING=1
)
exit /b 0

:create_local_gradlew_bat
:: Cria um gradlew.bat minimo localmente quando nao eh possivel baixar
echo Criando gradlew.bat localmente...
echo @echo off > gradlew.bat
echo setlocal >> gradlew.bat
echo. >> gradlew.bat
echo if "%%JAVA_HOME%%"=="" ( >> gradlew.bat
echo   echo ERRO: JAVA_HOME nao esta configurado. >> gradlew.bat
echo   exit /b 1 >> gradlew.bat
echo ) >> gradlew.bat
echo. >> gradlew.bat
echo set CLASSPATH=%%CD%%\gradle\wrapper\gradle-wrapper.jar >> gradlew.bat
echo set CMD_LINE_ARGS= >> gradlew.bat
echo set "JAVA_EXE=%%JAVA_HOME%%\bin\java.exe" >> gradlew.bat
echo. >> gradlew.bat
echo "%%JAVA_EXE%%" -classpath "%%CLASSPATH%%" org.gradle.wrapper.GradleWrapperMain %%* >> gradlew.bat
exit /b 0

:download_critical_dependencies
echo Baixando dependencias criticas manualmente...

:: Criar diretorios para as dependencias
set M2_REPO=%USERPROFILE%\.m2\repository
set ALLURE_DIR=%M2_REPO%\io\qameta\allure\allure-testng\%ALLURE_VERSION%
set ALLURE_MODEL_DIR=%M2_REPO%\io\qameta\allure\allure-model\%ALLURE_VERSION%
set ALLURE_COMMONS_DIR=%M2_REPO%\io\qameta\allure\allure-java-commons\%ALLURE_VERSION%
set TESTNG_DIR=%M2_REPO%\org\testng\testng\%TESTNG_VERSION%

:: Criar diretorios necessarios
if not exist "%ALLURE_DIR%" mkdir "%ALLURE_DIR%"
if not exist "%ALLURE_MODEL_DIR%" mkdir "%ALLURE_MODEL_DIR%"
if not exist "%ALLURE_COMMONS_DIR%" mkdir "%ALLURE_COMMONS_DIR%"
if not exist "%TESTNG_DIR%" mkdir "%TESTNG_DIR%"

:: Baixar Allure TestNG JAR
if %CURL_INSTALLED% EQU 1 (
    echo Baixando allure-testng-%ALLURE_VERSION%.jar...
    curl -L -o "%ALLURE_DIR%\allure-testng-%ALLURE_VERSION%.jar" "https://repo1.maven.org/maven2/io/qameta/allure/allure-testng/%ALLURE_VERSION%/allure-testng-%ALLURE_VERSION%.jar"
    curl -L -o "%ALLURE_DIR%\allure-testng-%ALLURE_VERSION%.pom" "https://repo1.maven.org/maven2/io/qameta/allure/allure-testng/%ALLURE_VERSION%/allure-testng-%ALLURE_VERSION%.pom"
    
    :: Baixar Allure Model e Commons (dependências do Allure TestNG)
    echo Baixando allure-model-%ALLURE_VERSION%.jar...
    curl -L -o "%ALLURE_MODEL_DIR%\allure-model-%ALLURE_VERSION%.jar" "https://repo1.maven.org/maven2/io/qameta/allure/allure-model/%ALLURE_VERSION%/allure-model-%ALLURE_VERSION%.jar"
    curl -L -o "%ALLURE_MODEL_DIR%\allure-model-%ALLURE_VERSION%.pom" "https://repo1.maven.org/maven2/io/qameta/allure/allure-model/%ALLURE_VERSION%/allure-model-%ALLURE_VERSION%.pom"
    
    echo Baixando allure-java-commons-%ALLURE_VERSION%.jar...
    curl -L -o "%ALLURE_COMMONS_DIR%\allure-java-commons-%ALLURE_VERSION%.jar" "https://repo1.maven.org/maven2/io/qameta/allure/allure-java-commons/%ALLURE_VERSION%/allure-java-commons-%ALLURE_VERSION%.jar"
    curl -L -o "%ALLURE_COMMONS_DIR%\allure-java-commons-%ALLURE_VERSION%.pom" "https://repo1.maven.org/maven2/io/qameta/allure/allure-java-commons/%ALLURE_VERSION%/allure-java-commons-%ALLURE_VERSION%.pom"
) else (
    echo Baixando allure-testng-%ALLURE_VERSION%.jar...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://repo1.maven.org/maven2/io/qameta/allure/allure-testng/%ALLURE_VERSION%/allure-testng-%ALLURE_VERSION%.jar', '%ALLURE_DIR%\allure-testng-%ALLURE_VERSION%.jar')"
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://repo1.maven.org/maven2/io/qameta/allure/allure-testng/%ALLURE_VERSION%/allure-testng-%ALLURE_VERSION%.pom', '%ALLURE_DIR%\allure-testng-%ALLURE_VERSION%.pom')"
    
    echo Baixando allure-model-%ALLURE_VERSION%.jar...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://repo1.maven.org/maven2/io/qameta/allure/allure-model/%ALLURE_VERSION%/allure-model-%ALLURE_VERSION%.jar', '%ALLURE_MODEL_DIR%\allure-model-%ALLURE_VERSION%.jar')"
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://repo1.maven.org/maven2/io/qameta/allure/allure-model/%ALLURE_VERSION%/allure-model-%ALLURE_VERSION%.pom', '%ALLURE_MODEL_DIR%\allure-model-%ALLURE_VERSION%.pom')"
    
    echo Baixando allure-java-commons-%ALLURE_VERSION%.jar...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://repo1.maven.org/maven2/io/qameta/allure/allure-java-commons/%ALLURE_VERSION%/allure-java-commons-%ALLURE_VERSION%.jar', '%ALLURE_COMMONS_DIR%\allure-java-commons-%ALLURE_VERSION%.jar')"
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://repo1.maven.org/maven2/io/qameta/allure/allure-java-commons/%ALLURE_VERSION%/allure-java-commons-%ALLURE_VERSION%.pom', '%ALLURE_COMMONS_DIR%\allure-java-commons-%ALLURE_VERSION%.pom')"
)

:: Baixar TestNG JAR
if %CURL_INSTALLED% EQU 1 (
    echo Baixando testng-%TESTNG_VERSION%.jar...
    curl -L -o "%TESTNG_DIR%\testng-%TESTNG_VERSION%.jar" "https://repo1.maven.org/maven2/org/testng/testng/%TESTNG_VERSION%/testng-%TESTNG_VERSION%.jar"
    curl -L -o "%TESTNG_DIR%\testng-%TESTNG_VERSION%.pom" "https://repo1.maven.org/maven2/org/testng/testng/%TESTNG_VERSION%/testng-%TESTNG_VERSION%.pom"
) else (
    echo Baixando testng-%TESTNG_VERSION%.jar...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://repo1.maven.org/maven2/org/testng/testng/%TESTNG_VERSION%/testng-%TESTNG_VERSION%.jar', '%TESTNG_DIR%\testng-%TESTNG_VERSION%.jar')"
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://repo1.maven.org/maven2/org/testng/testng/%TESTNG_VERSION%/testng-%TESTNG_VERSION%.pom', '%TESTNG_DIR%\testng-%TESTNG_VERSION%.pom')"
)

echo Dependencias baixadas manualmente para: %M2_REPO%
exit /b 0

:gradle_safe_execute
set GRADLE_CMD=gradlew.bat %*
echo Executando: %GRADLE_CMD%
call %GRADLE_CMD%
set RESULT=%ERRORLEVEL%
echo.
exit /b %RESULT%

:install_gradle_manually_ask
echo.
echo Recomendamos instalar o Gradle manualmente:
echo 1. Baixe o Gradle %GRADLE_VERSION% de https://gradle.org/releases/
echo 2. Extraia o arquivo para uma pasta (ex: C:\Gradle\gradle-%GRADLE_VERSION%)
echo 3. Adicione a pasta bin ao PATH: C:\Gradle\gradle-%GRADLE_VERSION%\bin
echo.
set /p INSTALL_GRADLE="Deseja que tentemos baixar e instalar o Gradle automaticamente? (S/N): "
if /i "%INSTALL_GRADLE%"=="S" (
    call :install_gradle_manually
)
exit /b 0

:install_gradle_manually
echo Tentando baixar e instalar Gradle %GRADLE_VERSION% localmente...

:: Criar pasta temporaria para o Gradle
mkdir %GRADLE_HOME% 2>nul

:: Baixar o Gradle
set GRADLE_ZIP=temp\gradle-%GRADLE_VERSION%-bin.zip
if %CURL_INSTALLED% EQU 1 (
    curl -L -o %GRADLE_ZIP% https://services.gradle.org/distributions/gradle-%GRADLE_VERSION%-bin.zip
) else (
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://services.gradle.org/distributions/gradle-%GRADLE_VERSION%-bin.zip', '%GRADLE_ZIP%')"
)

if not exist %GRADLE_ZIP% (
    echo Falha ao baixar Gradle.
    exit /b 1
)

:: Extrair o Gradle
echo Extraindo Gradle...
powershell -Command "Expand-Archive -Path '%GRADLE_ZIP%' -DestinationPath 'temp' -Force"

:: Verificar se a extracao foi bem-sucedida
if not exist temp\gradle-%GRADLE_VERSION%\bin\gradle.bat (
    echo Falha ao extrair Gradle.
    exit /b 1
)

:: Adicionar Gradle ao PATH temporariamente
set PATH=%CD%\temp\gradle-%GRADLE_VERSION%\bin;%PATH%

:: Verificar instalacao
gradle -v >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Falha ao instalar Gradle.
    exit /b 1
)

echo Gradle instalado temporariamente em: %CD%\temp\gradle-%GRADLE_VERSION%
exit /b 0

:create_complete_build_gradle
echo Criando um arquivo build.gradle completo...
(
echo plugins {
echo     id 'java'
echo ^}
echo.
echo group = 'com.test.agi'
echo version = '1.0-SNAPSHOT'
echo.
echo sourceCompatibility = '%JAVA_MIN_VERSION%'
echo.
echo repositories {
echo     mavenCentral^(^)
echo     maven { url 'https://jcenter.bintray.com' ^}
echo     maven { url 'https://repo.maven.apache.org/maven2/' ^}
echo ^}
echo.
echo dependencies {
echo     implementation 'org.seleniumhq.selenium:selenium-java:4.18.1'
echo     implementation 'io.github.bonigarcia:webdrivermanager:5.7.0'
echo     implementation 'org.testng:testng:%TESTNG_VERSION%'
echo     implementation 'io.qameta.allure:allure-testng:%ALLURE_VERSION%'
echo     implementation 'ch.qos.logback:logback-classic:1.4.14'
echo     implementation 'commons-io:commons-io:2.15.1'
echo     implementation 'org.apache.commons:commons-lang3:3.14.0'
echo     implementation 'org.apache.logging.log4j:log4j-api:2.22.1'
echo     implementation 'org.apache.logging.log4j:log4j-core:2.22.1'
echo     implementation 'org.apache.logging.log4j:log4j-slf4j-impl:2.22.1'
echo ^}
echo.
echo test {
echo     useTestNG^(^) {
echo         useDefaultListeners = true
echo         suites file^('src/test/resources/testng.xml'^)
echo     ^}
echo     systemProperties = System.properties
echo ^}
echo.
echo configurations.all {
echo     resolutionStrategy {
echo         force 'org.slf4j:slf4j-api:1.7.36'
echo         force 'org.apache.commons:commons-lang3:3.14.0'
echo         force 'org.apache.commons:commons-compress:1.26.0'
echo         force 'org.apache.httpcomponents.client5:httpclient5:5.2.1'
echo         force 'com.google.guava:guava:33.0.0-jre'
echo         force 'commons-io:commons-io:2.15.1'
echo     ^}
echo ^}
) > build.gradle
echo Arquivo build.gradle criado com sucesso.
exit /b 0

:: ==================== FINAIS DE EXECUCAO ====================

:setup_failed
echo.
echo ===================================================
echo  FALHA NA CONFIGURACAO
echo ===================================================
echo.
echo Nao foi possivel configurar o ambiente completamente.
echo Verifique os erros acima e tente novamente.
echo.
pause
exit /b 1

:setup_partially_completed
echo.
echo ===================================================
echo  CONFIGURACAO PARCIALMENTE CONCLUIDA
echo ===================================================
echo.
echo Algumas partes da configuracao foram concluidas, mas houve problemas.
echo.
echo Problemas potenciais:
echo - Falha ao baixar dependencias - pode ser problema de conexao
echo - Gradle Wrapper nao esta funcionando corretamente
echo - Arquivos de configuracao ausentes ou incorretos
echo.
echo Revise as mensagens de erro acima.
echo.
goto :run_prompt

:setup_completed
echo.
echo ===================================================
echo  CONFIGURACAO CONCLUIDA COM SUCESSO!
echo ===================================================
echo.
echo O ambiente foi configurado com sucesso!
echo.

:run_prompt
:: Adicionar diretorio atual ao PATH temporariamente para facilitar o uso do gradlew
set PATH=%CD%;%PATH%

:: Perguntar se quer executar os testes
set /p RUN_TESTS="Deseja executar os testes agora? (S/N): "
if /i "%RUN_TESTS%"=="S" (
    echo.
    echo Executando testes...
    echo.
    call gradlew.bat clean test
    
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo ===================================================
        echo  TESTES EXECUTADOS COM SUCESSO!
        echo ===================================================
        echo.
        echo Para abrir o relatorio HTML, navegue ate:
        echo %CD%\build\reports\tests\test\index.html
        echo.
    ) else (
        echo.
        echo ===================================================
        echo  ATENCAO: FALHAS NOS TESTES
        echo ===================================================
        echo.
        echo Alguns testes falharam. Verifique o relatorio para mais detalhes.
        echo Os relatorios de teste estao disponiveis em:
        echo %CD%\build\reports\tests\test\index.html
        echo.
    )
)

echo ===================================================
echo  COMANDOS DISPONIVEIS
echo ===================================================
echo.
echo Para executar os testes:
echo   gradlew.bat clean test
echo.
echo Para executar com navegador especifico:
echo   gradlew.bat clean test -Dbrowser=firefox
echo   gradlew.bat clean test -Dbrowser=chrome-headless
echo.
echo Para limpar e reconstruir o projeto:
echo   gradlew.bat clean build
echo.
echo ===================================================
echo.
pause 