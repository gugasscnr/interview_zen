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

# Verificar se o Maven está instalado
echo "Verificando instalação do Maven..."
if ! command -v mvn &> /dev/null; then
    echo "Maven não encontrado. Por favor, instale o Maven 3.6 ou superior."
    echo "Ubuntu/Debian: sudo apt install maven"
    echo "macOS: brew install maven"
    exit 1
fi
echo "Maven encontrado. Verificando versão..."
mvn -version
echo

# Criar diretórios de log
echo "Criando diretórios de log..."
mkdir -p logs
echo "Diretório de logs criado."
echo

# Resolver dependências do Maven
echo "Baixando dependências do projeto..."
mvn dependency:resolve
if [ $? -ne 0 ]; then
    echo "Erro ao baixar dependências. Verifique sua conexão com a internet."
    exit 1
fi
echo "Dependências baixadas com sucesso."
echo

# Gerar wrapper Maven
echo "Gerando Maven Wrapper..."
mvn wrapper:wrapper
if [ $? -ne 0 ]; then
    echo "Erro ao gerar Maven Wrapper."
    exit 1
fi
echo "Maven Wrapper gerado com sucesso."
echo

# Tornar o wrapper executável
echo "Tornando wrapper executável..."
chmod +x mvnw
echo "Wrapper executável configurado."
echo

echo "==================================================="
echo " Ambiente configurado com sucesso!"
echo "==================================================="
echo
echo "Para executar os testes, use:"
echo "./mvnw clean test"
echo
echo "Para executar com um navegador específico:"
echo "./mvnw clean test -Dbrowser=firefox"
echo "./mvnw clean test -Dbrowser=chrome-headless"
echo 