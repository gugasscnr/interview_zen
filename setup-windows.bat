@echo off
echo ===================================================
echo  Configuracao do Ambiente de Testes do Blog Agi
echo ===================================================
echo.

:: Verificar se o Java está instalado
echo Verificando instalacao do Java...
java -version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Java nao encontrado. Por favor, instale o JDK 11 ou superior.
    echo Download: https://www.oracle.com/java/technologies/javase-jdk11-downloads.html
    echo Ou: https://adoptopenjdk.net/
    pause
    exit /b 1
)
echo Java encontrado. Verificando versao...
java -version
echo.

:: Verificar se o Maven está instalado
echo Verificando instalacao do Maven...
mvn -version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Maven nao encontrado. Por favor, instale o Maven 3.6 ou superior.
    echo Download: https://maven.apache.org/download.cgi
    pause
    exit /b 1
)
echo Maven encontrado. Verificando versao...
mvn -version
echo.

:: Criar diretórios de log
echo Criando diretorios de log...
if not exist logs mkdir logs
echo Diretorio de logs criado.
echo.

:: Resolver dependências do Maven
echo Baixando dependencias do projeto...
mvn dependency:resolve
if %ERRORLEVEL% NEQ 0 (
    echo Erro ao baixar dependencias. Verifique sua conexao com a internet.
    pause
    exit /b 1
)
echo Dependencias baixadas com sucesso.
echo.

:: Gerar wrapper Maven
echo Gerando Maven Wrapper...
mvn wrapper:wrapper
if %ERRORLEVEL% NEQ 0 (
    echo Erro ao gerar Maven Wrapper.
    pause
    exit /b 1
)
echo Maven Wrapper gerado com sucesso.
echo.

echo ===================================================
echo  Ambiente configurado com sucesso!
echo ===================================================
echo.
echo Para executar os testes, use:
echo mvn clean test
echo.
echo Para executar com um navegador especifico:
echo mvn clean test -Dbrowser=firefox
echo mvn clean test -Dbrowser=chrome-headless
echo.
echo Pressione qualquer tecla para sair...
pause > nul 