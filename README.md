# Testes Automatizados do Blog Agi

Este projeto contém testes automatizados para validar o blog do Agi (https://blogdoagi.com.br/) utilizando Java, Selenium WebDriver, TestNG e Gradle.

## Requisitos

- Java 11 ou superior
- Gradle 7.0 ou superior (opcional, o wrapper está incluído)
- Navegadores: Chrome e/ou Firefox
- Conexão com a Internet

## Configuração Rápida (Recomendado)

Para facilitar a configuração do projeto, disponibilizamos scripts que verificam as dependências e preparam o ambiente para execução dos testes.

### Windows
```shell
# Execute o script de setup (abra o cmd como administrador)
setup-windows.bat
```

### Problemas conhecidos no Windows

Se você encontrar problemas com o script de configuração, especialmente relacionados ao curl:

1. **Script alternativo sem curl**: Execute `gerar-wrapper-alt.bat` para criar os arquivos do Gradle Wrapper sem usar curl
   
2. **Instalação manual do Gradle**:
   - Baixe o Gradle do site oficial: https://gradle.org/releases/
   - Extraia para uma pasta no seu computador (ex: `C:\Gradle\gradle-8.7`)
   - Adicione a pasta bin ao seu PATH: `C:\Gradle\gradle-8.7\bin`
   - Teste com o comando: `gradle -v`

3. **Download manual dos arquivos do wrapper**:
   - Crie a pasta `gradle/wrapper` no diretório do projeto
   - Baixe o arquivo JAR: https://github.com/gradle/gradle/raw/master/gradle/wrapper/gradle-wrapper.jar
   - Salve-o na pasta `gradle/wrapper`
   - Crie manualmente o arquivo `gradle/wrapper/gradle-wrapper.properties` com o conteúdo:
     ```
     distributionBase=GRADLE_USER_HOME
     distributionPath=wrapper/dists
     distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-bin.zip
     zipStoreBase=GRADLE_USER_HOME
     zipStorePath=wrapper/dists
     ```

### Linux/macOS
```shell
# Dê permissão de execução ao script
chmod +x setup-linux.sh

# Execute o script de setup
./setup-linux.sh
```

Após a execução bem-sucedida do script, o ambiente estará pronto para executar os testes.

## Guia de Instalação Manual

Caso prefira configurar o ambiente manualmente, siga as instruções abaixo:

### 1. Instalação do Java JDK 11 ou Superior

#### Windows
1. Acesse o site oficial da Oracle para download: https://www.oracle.com/java/technologies/javase-jdk11-downloads.html
   - Ou use o OpenJDK: https://adoptopenjdk.net/
2. Baixe o instalador do JDK para Windows
3. Execute o instalador e siga as instruções na tela
4. Configure as variáveis de ambiente:
   - Adicione `JAVA_HOME` apontando para o diretório de instalação (ex: `C:\Program Files\Java\jdk-11.0.XX`)
   - Adicione `%JAVA_HOME%\bin` ao `Path`
5. Verifique a instalação abrindo o Prompt de Comando e digitando:
   ```
   java -version
   ```

#### Linux (Ubuntu/Debian)
```shell
# Instale o OpenJDK 11
sudo apt update
sudo apt install openjdk-11-jdk

# Verifique a instalação
java -version
```

#### macOS
```shell
# Com Homebrew
brew install openjdk@11

# Configure as variáveis de ambiente no ~/.zshrc ou ~/.bash_profile
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 11)' >> ~/.zshrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.zshrc
source ~/.zshrc

# Verifique a instalação
java -version
```

### 2. Instalação do Gradle (Opcional)

O projeto inclui um Gradle Wrapper (`gradlew`), então não é necessário instalar o Gradle. Porém, caso deseje instalar:

#### Windows
1. Acesse o site oficial do Gradle: https://gradle.org/install/
2. Baixe o arquivo binário (zip)
3. Extraia o arquivo para um diretório de sua escolha (ex: `C:\Gradle\gradle-8.7`)
4. Configure as variáveis de ambiente:
   - Adicione `GRADLE_HOME` apontando para o diretório onde o Gradle foi extraído
   - Adicione `%GRADLE_HOME%\bin` ao `Path`
5. Verifique a instalação abrindo o Prompt de Comando e digitando:
   ```
   gradle -v
   ```

#### Linux (Ubuntu/Debian)
```shell
# Instale o Gradle
sudo apt update
sudo apt install gradle

# Verifique a instalação
gradle -v
```

#### macOS
```shell
# Com Homebrew
brew install gradle

# Verifique a instalação
gradle -v
```

### 3. Instalação dos Navegadores

#### Chrome
- Download: https://www.google.com/chrome/
- O WebDriverManager irá configurar o ChromeDriver automaticamente

#### Firefox
- Download: https://www.mozilla.org/firefox/
- O WebDriverManager irá configurar o GeckoDriver automaticamente

### 4. Configuração do Projeto

1. Clone o repositório:
```shell
git clone <URL-do-repositorio>
cd <nome-do-diretorio>
```

2. Verifique se todas as dependências foram baixadas corretamente:
```shell
# No Windows
gradlew dependencies

# No Linux/macOS
./gradlew dependencies
```

## Estrutura do Projeto

O projeto segue o padrão Page Object Model (POM) e está estruturado da seguinte forma:

```
├── src
│   ├── main
│   │   └── java
│   │       └── com
│   │           └── test
│   │               └── agi
│   │                   └── pages
│   │                       ├── BasePage.java        # Classe base com métodos comuns para as páginas
│   │                       └── BlogPage.java        # Page Object para o Blog do Agi
│   └── test
│       ├── java
│       │   └── com
│       │       └── test
│       │           └── agi
│       │               ├── config
│       │               │   └── BaseTest.java        # Configuração base para todos os testes
│       │               ├── tests
│       │               │   └── BuscaTests.java      # Casos de teste para funcionalidade de busca
│       │               └── utils
│       │                   └── TestData.java        # Dados de teste parametrizados
│       └── resources
│           ├── log4j2.xml                           # Configuração de logging
│           └── testng.xml                           # Configuração do TestNG
├── logs                                             # Diretório para logs de execução
├── build.gradle                                     # Configuração do Gradle e dependências
├── settings.gradle                                  # Configuração do nome do projeto
└── README.md                                        # Este arquivo
```

## Casos de Teste Implementados

1. **Validação da Funcionalidade de Busca**
   - Pesquisa por termos válidos (poupança, investimento, crédito)
   - Verifica se os resultados contêm o termo pesquisado
   - Valida a filtragem de artigos irrelevantes

2. **Tratamento de Inputs Inválidos**
   - Pesquisa com campo vazio
   - Pesquisa com caracteres especiais
   - Validação de mensagens de erro/retorno adequadas

## Como Executar os Testes

### Windows

```shell
# Com Gradle Wrapper
gradlew clean test
```

### Linux/macOS

```shell
# Com Gradle Wrapper
./gradlew clean test
```

### Executar com Navegador Específico

Por padrão, os testes são executados no Chrome. Para executar em outro navegador:

```shell
# Firefox
./gradlew clean test -Dbrowser=firefox

# Chrome em modo headless (sem interface gráfica)
./gradlew clean test -Dbrowser=chrome-headless
```

## Relatórios

Após a execução, os relatórios podem ser encontrados em:

- Relatório TestNG: `build/reports/tests/test/index.html`
- Relatório Allure: `build/allure-results`

### Configuração do Allure

#### Windows
```shell
# Instale o Scoop (gerenciador de pacotes para Windows)
# Abra o PowerShell como administrador e execute:
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')

# Instale o Allure com Scoop
scoop install allure

# Ou baixe o arquivo zip diretamente:
# https://github.com/allure-framework/allure2/releases
```

#### Linux
```shell
# Ubuntu/Debian
sudo apt-add-repository ppa:qameta/allure
sudo apt-get update
sudo apt-get install allure
```

#### macOS
```shell
# Usando Homebrew
brew install allure
```

### Gerando e Visualizando Relatórios Allure

```shell
# Gere o relatório
allure generate build/allure-results -o build/allure-report --clean

# Abra o relatório
allure open build/allure-report
```

## Solução de Problemas

Encontrou algum problema na instalação ou execução? Consulte nosso guia de solução de problemas:
- [Problemas Comuns e Soluções](PROBLEMAS-COMUNS.md)

## CI/CD

Este projeto inclui configuração para integração contínua utilizando GitHub Actions. A configuração pode ser encontrada no arquivo `.github/workflows/gradle.yml`.

## Recursos Adicionais

- [Documentação oficial do Selenium](https://www.selenium.dev/documentation/)
- [Documentação do TestNG](https://testng.org/doc/)
- [Documentação do Gradle](https://docs.gradle.org/current/userguide/userguide.html)
- [Documentação do Allure](https://docs.qameta.io/allure/)
- [Documentação do WebDriverManager](https://github.com/bonigarcia/webdrivermanager)

## Extensão do Projeto

Para adicionar novos testes ou expandir o projeto, consulte o guia:
- [Como Adicionar Novos Testes](COMO-ADICIONAR-TESTES.md)

## Contato

Em caso de dúvidas ou problemas, por favor abra uma issue no repositório. 

