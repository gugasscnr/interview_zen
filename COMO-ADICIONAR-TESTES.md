# Guia: Como Adicionar Novos Testes

Este documento explica como adicionar novos casos de teste ao projeto de automação do Blog do Agi.

## Estrutura de Arquivos para Novos Testes

Para adicionar um novo cenário de teste, você geralmente precisará:

1. Atualizar ou criar Page Objects para representar as novas páginas/componentes
2. Adicionar métodos de teste nas classes de teste existentes ou criar novas classes
3. Opcionalmente, adicionar novos dados de teste no TestData.java

## Passo a Passo

### 1. Verificar se precisa criar novos Page Objects

Se o seu teste interage com uma nova página ou componente:

1. Crie uma nova classe na pasta `src/main/java/com/test/agi/pages/`
2. Estenda a classe `BasePage`
3. Implemente os locators e métodos necessários

Exemplo:

```java
package com.test.agi.pages;

import io.qameta.allure.Step;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public class NovaPage extends BasePage {
    
    // Locators
    private final By elementoExemplo = By.id("exemplo");
    
    public NovaPage(WebDriver driver) {
        super(driver);
    }
    
    @Step("Realizar ação de exemplo")
    public NovaPage acaoDeExemplo() {
        clickElement(elementoExemplo);
        return this;
    }
}
```

### 2. Criar novos casos de teste

Para adicionar novos testes:

1. Crie uma nova classe ou use uma existente em `src/test/java/com/test/agi/tests/`
2. Estenda a classe `BaseTest`
3. Implemente os métodos de teste anotados com `@Test`

Exemplo:

```java
package com.test.agi.tests;

import com.test.agi.config.BaseTest;
import com.test.agi.pages.NovaPage;
import io.qameta.allure.Description;
import io.qameta.allure.Severity;
import io.qameta.allure.SeverityLevel;
import io.qameta.allure.Story;
import org.testng.Assert;
import org.testng.annotations.Test;

public class NovosTestes extends BaseTest {

    @Test
    @Description("Descrição do novo teste")
    @Severity(SeverityLevel.NORMAL)
    @Story("Nova funcionalidade")
    public void novoTesteDeExemplo() {
        logger.info("Iniciando novo teste de exemplo");
        
        NovaPage novaPage = new NovaPage(driver);
        // Implementar lógica do teste
        
        // Asserções
        Assert.assertTrue(true, "Mensagem em caso de falha");
    }
}
```

### 3. Adicionar a nova classe de testes ao testng.xml

Abra o arquivo `src/test/resources/testng.xml` e adicione sua nova classe:

```xml
<!DOCTYPE suite SYSTEM "https://testng.org/testng-1.0.dtd" >
<suite name="BlogAgiTestSuite" verbose="1">
    <test name="BuscaTests">
        <classes>
            <class name="com.test.agi.tests.BuscaTests"/>
        </classes>
    </test>
    <!-- Adicione seu novo teste aqui -->
    <test name="NovosTestes">
        <classes>
            <class name="com.test.agi.tests.NovosTestes"/>
        </classes>
    </test>
</suite>
```

### 4. Criar dados de teste parametrizados (opcional)

Se seu teste usar dados parametrizados:

1. Abra a classe `TestData.java` em `src/test/java/com/test/agi/utils/`
2. Adicione um novo método DataProvider:

```java
@DataProvider(name = "novosExemplos")
public static Object[][] novosExemplos() {
    return new Object[][] {
        {"dado1", 123},
        {"dado2", 456}
    };
}
```

3. Use no seu teste com:

```java
@Test(dataProvider = "novosExemplos", dataProviderClass = TestData.class)
public void testParametrizado(String texto, int numero) {
    // Implementar teste
}
```

## Boas Práticas

1. **Nomenclatura**: Use nomes descritivos e em português para os métodos de teste
2. **Documentação**: Documente o teste com anotações de Allure
3. **Asserções**: Certifique-se de que cada teste tenha asserções claras
4. **Independência**: Cada teste deve ser independente, não dependa de outros testes
5. **Screenshots**: Use o método de captura de screenshots em caso de falhas importantes

## Executar os Novos Testes

Execute os testes normalmente:

```shell
mvn clean test
```

Ou execute apenas sua nova classe de teste:

```shell
mvn clean test -Dtest=NovosTestes
``` 