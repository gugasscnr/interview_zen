# Como Resolver Erro de Dependências

Se você está enfrentando o erro:

```
Could not find io.qameta.allure:allure-testng:7.9.0
```

Ou qualquer outro problema de dependências, siga os passos abaixo:

## Opção 1: Rodar a sequência de comandos

Execute estes comandos na ordem:

```batch
gradlew.bat cleanBuildCache
gradlew.bat --refresh-dependencies
gradlew.bat clean
gradlew.bat build -x test
gradlew.bat test
```

## Opção 2: Usar os scripts de limpeza

1. Execute o script `limpar-e-reconstruir.bat`:
   ```
   limpar-e-reconstruir.bat
   ```

2. Se o problema persistir, execute o script para baixar dependências manualmente:
   ```
   baixar-dependencias-manualmente.bat
   ```

3. Tente novamente:
   ```
   gradlew.bat clean test
   ```

## Opção 3: Verificar configuração do Gradle

1. Certifique-se de estar usando o comandos corretos no Windows:
   - Use `gradlew.bat` em vez de apenas `gradlew`
   - Ou use `.\gradlew.bat` ou `./gradlew.bat`
   - Alternativamente, use o arquivo `gradlew.cmd` que criamos (simplesmente digite `gradlew`)

2. Verifique se o Gradle Wrapper foi baixado corretamente:
   - Deve existir um arquivo `gradlew.bat`
   - Deve existir uma pasta `gradle/wrapper` com os arquivos de configuração

## Opção 4: Instalar o Gradle manualmente

Se tudo falhar, instale o Gradle diretamente:

1. Baixe do site oficial: https://gradle.org/releases/
2. Extraia para uma pasta (ex: `C:\Gradle\gradle-8.7`)
3. Adicione ao PATH: `C:\Gradle\gradle-8.7\bin`
4. Verifique a instalação: `gradle -v`
5. Execute: `gradle clean test`

## Problema específico com Allure e TestNG

O projeto usa Allure para relatórios e TestNG para testes. Se houver conflitos:

1. Edite o arquivo `build.gradle`
2. Verifique se a versão do Allure está correta (deve ser 2.25.0, não 7.9.0)
3. Certifique-se de que o TestNG esteja como `testImplementation` e não `implementation`
4. Adicione `resolutionStrategy` para forçar versões específicas 