# Testes Automatizados do Blog Agi

Este projeto contém testes automatizados para validar o blog do Agi (https://blogdoagi.com.br/) utilizando Java, Selenium WebDriver, TestNG e Gradle.

## Requisitos

- Java 11 ou superior
- Gradle 7.0 ou superior (opcional, o wrapper está incluído)
- Navegadores: Chrome e/ou Firefox
- Conexão com a Internet

## Índice
- [Windows](#windows)
- [Linux](#linux)
- [macOS](#macos)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Casos de Teste](#casos-de-teste)
- [Integração Contínua (CI/CD)](#integração-contínua-cicd)
- [Solução de Problemas](#solução-de-problemas)

## Windows

### Instalação no Windows

1. **Instalação rápida com script**
   ```shell
   # Execute o script de setup (abra o cmd como administrador)
   ./setup-windows.bat
   ```

2. **Instalação manual**
   - Instale o JDK 11+ e configure `JAVA_HOME` nas variáveis de ambiente
   - Instale o Chrome e/ou Firefox
   - O Gradle Wrapper está incluído no projeto

### Executando Testes no Windows

```shell
# Execução padrão com Chrome
gradlew clean test

# Com Firefox
gradlew clean test -Dbrowser=firefox

# Com Chrome em modo headless
gradlew clean test -Dbrowser=chrome-headless
```

### Relatórios no Windows

1. **Acessando relatórios gerados**
   - TestNG: Abra `build/reports/tests/test/index.html` no navegador
   
2. **Gerando relatórios Allure**
   ```shell
   # Instale o Allure via Scoop
   scoop install allure

   # Gere e abra o relatório
   allure generate build/allure-results -o build/allure-report --clean
   allure open build/allure-report
   ```

## Linux

### Instalação no Linux

1. **Instalação rápida com script**
   ```shell
   # Dê permissão de execução e execute o script
   chmod +x setup-linux.sh
   ./setup-linux.sh
   ```

2. **Instalação manual**
   ```shell
   # Instale o OpenJDK 11
   sudo apt update
   sudo apt install openjdk-11-jdk
   
   # Instale o Chrome
   wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
   sudo apt install ./google-chrome-stable_current_amd64.deb
   ```

### Executando Testes no Linux

```shell
# Execução padrão com Chrome
./gradlew clean test

# Com Firefox
./gradlew clean test -Dbrowser=firefox

# Com Chrome em modo headless
./gradlew clean test -Dbrowser=chrome-headless
```

### Relatórios no Linux

1. **Acessando relatórios gerados**
   - TestNG: Abra `build/reports/tests/test/index.html` no navegador
   
2. **Gerando relatórios Allure**
   ```shell
   # Instale o Allure
   sudo apt-add-repository ppa:qameta/allure
   sudo apt-get update
   sudo apt-get install allure

   # Gere e abra o relatório
   allure generate build/allure-results -o build/allure-report --clean
   allure open build/allure-report
   ```

## macOS

### Instalação no macOS

1. **Instalação com Homebrew**
   ```shell
   # Instale o Java 11
   brew install openjdk@11
   
   # Configure variáveis de ambiente
   echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 11)' >> ~/.zshrc
   echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.zshrc
   source ~/.zshrc
   
   # Instale o Chrome
   brew install --cask google-chrome
   ```

### Executando Testes no macOS

```shell
# Execução padrão com Chrome
./gradlew clean test

# Com Firefox
./gradlew clean test -Dbrowser=firefox

# Com Chrome em modo headless
./gradlew clean test -Dbrowser=chrome-headless
```

### Relatórios no macOS

1. **Acessando relatórios gerados**
   - TestNG: Abra `build/reports/tests/test/index.html` no navegador
   
2. **Gerando relatórios Allure**
   ```shell
   # Instale o Allure
   brew install allure

   # Gere e abra o relatório
   allure generate build/allure-results -o build/allure-report --clean
   allure open build/allure-report
   ```

## Estrutura do Projeto

O projeto segue o padrão Page Object Model (POM) com as seguintes otimizações:

- **Navegador único para todos os testes**: Uma única instância do navegador é reutilizada
- **Esperas explícitas**: Timeout padrão configurado para 20 segundos
- **Seletores CSS robustos**: Evita problemas com mudanças no layout do site

```
├── src/main/java/.../pages     # Contém os Page Objects (BasePage.java, BlogPage.java)
├── src/test/java/.../config    # Configuração dos testes (BaseTest.java)
├── src/test/java/.../tests     # Casos de teste (BuscaTests.java)
├── src/test/java/.../utils     # Utilitários e dados de teste (TestData.java)
├── src/test/resources          # Configurações do TestNG e logging
```

## Casos de Teste

- **Funcionalidade de Busca**: Pesquisa por termos como "consignado", "empréstimo", etc.
- Verifica se os resultados contêm o termo pesquisado no título ou conteúdo

## Integração Contínua (CI/CD)

Este projeto está configurado com GitHub Actions para execução automática dos testes.

### Recursos do GitHub Actions

- **Execução automática**: Em push/PR para branches main/master
- **Relatórios**: Publicados como artefatos e no GitHub Pages
- **Execução manual**: Disponível através da aba Actions no GitHub

### Visualizando os Resultados

1. Acesse a aba "Actions" no GitHub
2. Veja os artefatos gerados ou acesse o link do GitHub Pages

## Solução de Problemas

Encontrou algum problema? Consulte o guia [Problemas Comuns e Soluções](PROBLEMAS-COMUNS.md)

