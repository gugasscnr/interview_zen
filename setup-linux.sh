#!/bin/bash

echo "==================================================="
echo " Configuração do Ambiente de Testes do Blog Agi"
echo "==================================================="
echo

# Verificar se o Java está instalado
echo "Verificando instalação do Java..."
if ! command -v java &> /dev/null; then
    echo "Java não encontrado. Por favor, instale o JDK 11 ou superior."
    echo "Ubuntu/Debian: sudo apt install openjdk-11-jdk"
    echo "macOS: brew install openjdk@11"
    exit 1
fi
echo "Java encontrado. Verificando versão..."
java -version
echo

# Verificar se o Gradle está instalado
echo "Verificando instalação do Gradle..."
if ! command -v gradle &> /dev/null; then
    echo "Gradle não encontrado. Gerando Gradle Wrapper..."
    
    # Criar diretórios necessários
    echo "Criando diretórios necessários..."
    mkdir -p gradle/wrapper
    
    # Baixar arquivos do Gradle Wrapper
    echo "Baixando Gradle Wrapper..."
    
    curl -L -o gradlew https://raw.githubusercontent.com/gradle/gradle/master/gradlew
    echo "Baixado gradlew"
    
    curl -L -o gradle/wrapper/gradle-wrapper.jar https://github.com/gradle/gradle/raw/master/gradle/wrapper/gradle-wrapper.jar
    echo "Baixado gradle-wrapper.jar"
    
    # Criar arquivo gradle-wrapper.properties manualmente
    echo "Criando arquivo de propriedades do wrapper..."
    cat > gradle/wrapper/gradle-wrapper.properties << EOL
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\\://services.gradle.org/distributions/gradle-8.7-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOL
    
    # Configurar permissões
    echo "Configurando permissões..."
    chmod +x gradlew
    
    # Verificar se os arquivos essenciais foram criados
    if [ ! -f "gradlew" ]; then
        echo "ERRO: Falha ao criar gradlew"
        exit 1
    fi
    
    echo "Gradle Wrapper criado com sucesso."
else
    echo "Gradle encontrado. Verificando versão..."
    gradle -v
fi
echo

# Criar diretórios de log
echo "Criando diretórios de log..."
mkdir -p logs
echo "Diretório de logs criado."
echo

# Baixar dependências do projeto
echo "Baixando dependências do projeto..."
./gradlew dependencies --no-daemon
if [ $? -ne 0 ]; then
    echo "Erro ao baixar dependências. Verifique sua conexão com a internet."
    exit 1
fi
echo "Dependências baixadas com sucesso."
echo

echo "==================================================="
echo " Ambiente configurado com sucesso!"
echo "==================================================="
echo
echo "Para executar os testes, use:"
echo "./gradlew clean test"
echo
echo "Para executar com um navegador específico:"
echo "./gradlew clean test -Dbrowser=firefox"
echo "./gradlew clean test -Dbrowser=chrome-headless"
echo 