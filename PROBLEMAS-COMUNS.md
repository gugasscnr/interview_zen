# Guia de Solução de Problemas Comuns

Este documento descreve os problemas mais comuns encontrados durante a execução dos testes automatizados do Blog do Agi e suas soluções.

## Problemas de Instalação e Configuração

### Java não foi encontrado

**Problema**: Erro "java: command not found" ou "'java' não é reconhecido como um comando interno ou externo"

**Solução**:
1. Instale o JDK 11 ou superior
   - Windows: [Download JDK Oracle](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) ou [AdoptOpenJDK](https://adoptopenjdk.net/)
   - Linux: `sudo apt install openjdk-11-jdk`
   - macOS: `brew install openjdk@11`
2. Configure as variáveis de ambiente:
   - Windows:
     - Adicione `JAVA_HOME` nas variáveis de ambiente (ex: `C:\Program Files\Java\jdk-11.0.XX`)
     - Adicione `%JAVA_HOME%\bin` ao `Path`
   - Linux/macOS:
     ```bash
     echo 'export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))' >> ~/.bashrc
     echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
     source ~/.bashrc
     ```

### Gradle Wrapper não está funcionando

**Problema**: Erro ao executar o Gradle Wrapper (`gradlew` ou `gradlew.bat`)

**Solução**:
1. Verifique se o arquivo tem permissão de execução (Linux/macOS):
   ```bash
   chmod +x gradlew
   ```
2. Tente baixar novamente o wrapper:
   ```bash
   # Windows (requer curl)
   curl -o gradlew.bat https://raw.githubusercontent.com/gradle/gradle/master/gradlew.bat
   
   # Linux/macOS
   curl -o gradlew https://raw.githubusercontent.com/gradle/gradle/master/gradlew
   chmod +x gradlew
   ```
3. Se o problema persistir, instale o Gradle manualmente:
   - Windows: [Download Gradle](https://gradle.org/install/)
   - Linux: `sudo apt install gradle`
   - macOS: `brew install gradle`
   
   E use o comando `gradle` em vez de `gradlew`.

## Problemas Durante a Execução dos Testes

### WebDriver não consegue encontrar o navegador

**Problema**: Erro "The path to the driver executable must be set by the webdriver.chrome.driver system property"

**Solução**:
1. Verifique se o navegador está instalado (Chrome ou Firefox)
2. Atualize o WebDriverManager:
   ```bash
   ./gradlew --refresh-dependencies
   ```
3. Se o erro persistir, baixe o driver manualmente:
   - [ChromeDriver](https://sites.google.com/a/chromium.org/chromedriver/downloads)
   - [GeckoDriver (Firefox)](https://github.com/mozilla/geckodriver/releases)
   
   E configure o caminho manualmente na classe BaseTest.java:
   ```java
   System.setProperty("webdriver.chrome.driver", "/caminho/para/chromedriver");
   ```

### Erro "Element not found" ou "Element not interactable"

**Problema**: Os testes falham ao tentar interagir com elementos na página

**Solução**:
1. Verifique se o site alterou a estrutura HTML/CSS
2. Atualize os seletores CSS na classe BlogPage.java
3. Aumente o tempo de espera na classe BasePage.java:
   ```java
   protected static final Duration DEFAULT_TIMEOUT = Duration.ofSeconds(15); // Aumentar para 15 segundos
   ```
4. Use esperas explícitas para elementos específicos:
   ```java
   new WebDriverWait(driver, Duration.ofSeconds(20))
       .until(ExpectedConditions.visibilityOfElementLocated(locator));
   ```

### Erros de conexão com o site

**Problema**: Erro "Connection refused" ou "Failed to connect"

**Solução**:
1. Verifique sua conexão com a internet
2. Verifique se o site está disponível: [Blog do Agi](https://blogdoagi.com.br/)
3. Se você estiver usando proxy, configure-o:
   ```java
   Proxy proxy = new Proxy();
   proxy.setHttpProxy("endereco:porta");
   ChromeOptions options = new ChromeOptions();
   options.setCapability("proxy", proxy);
   ```

## Problemas com Gradle

### Erro ao baixar dependências

**Problema**: Erro "Could not resolve dependencies" ou "Connection to repository failed"

**Solução**:
1. Verifique sua conexão com a internet
2. Limpe o cache do Gradle:
   ```bash
   # Windows
   gradlew cleanBuildCache
   
   # Linux/macOS
   ./gradlew cleanBuildCache
   ```
3. Force o Gradle a baixar as dependências novamente:
   ```bash
   # Windows
   gradlew --refresh-dependencies
   
   # Linux/macOS
   ./gradlew --refresh-dependencies
   ```
4. Use um repositório alternativo no arquivo build.gradle:
   ```groovy
   repositories {
       mavenCentral()
       maven { url "https://repo1.maven.org/maven2" }
   }
   ```

### Erros ao executar os testes

**Problema**: Erro "Compilation failure" ou "No compiler is provided in this environment"

**Solução**:
1. Verifique se o JDK está configurado corretamente
2. Force o Gradle a usar um JDK específico:
   ```bash
   # Windows
   gradlew clean test -Dorg.gradle.java.home="C:\Program Files\Java\jdk-11.0.XX"
   
   # Linux/macOS
   ./gradlew clean test -Dorg.gradle.java.home="/usr/lib/jvm/java-11-openjdk"
   ```
3. Tente limpar o projeto e reconstruir:
   ```bash
   # Windows
   gradlew clean build
   
   # Linux/macOS
   ./gradlew clean build
   ```

## Problemas com Allure Reports

### Erro ao gerar relatórios Allure

**Problema**: Erro ao executar comandos Allure

**Solução**:
1. Instale o Allure command-line:
   - Windows: `scoop install allure` (requer [Scoop](https://scoop.sh/))
   - Linux: 
     ```bash
     sudo apt-add-repository ppa:qameta/allure
     sudo apt-get update
     sudo apt-get install allure
     ```
   - macOS: `brew install allure`
2. Use o plugin Allure do Gradle diretamente:
   ```bash
   # Windows
   gradlew allureReport allureServe
   
   # Linux/macOS
   ./gradlew allureReport allureServe
   ```
3. Se o problema persistir, use os relatórios TestNG padrão em `build/reports/tests/test/index.html`

## Contato e Suporte

Se o problema persistir ou não estiver listado aqui, abra uma issue no repositório com:
- Descrição detalhada do problema
- Logs completos do erro
- Ambiente de execução (SO, versão do Java, versão do Gradle)
- Passos para reproduzir o problema 