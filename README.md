# Testes Automatizados Blog Agi

Este repositório contém testes automatizados para o Blog da Agi, verificando a funcionalidade de busca.

## O que é testado

1. **Busca por termo específico** - Verifica se a busca por "consignado" retorna resultados relevantes
2. **Busca sem termo** - Verifica se ao realizar uma busca sem fornecer termo, são exibidos assuntos aleatórios

## Como executar os testes via GitHub Actions

### Passo 1: Faça um fork do repositório
- Acesse o repositório original no GitHub
- Clique no botão "Fork" no canto superior direito
- Aguarde a criação da cópia no seu perfil

### Passo 2: Habilite o GitHub Actions
- Acesse seu fork do repositório
- Clique na aba "Actions"
- Se aparecer um aviso de workflows desabilitados, clique em "I understand my workflows, go ahead and enable them"

### Passo 3: Execute os testes
- Na aba "Actions", localize o workflow "Testes Automatizados Blog Agi"
- Clique no botão "Run workflow" (botão azul com seta para baixo)
- Mantenha a branch "main" selecionada e clique em "Run workflow"

### Passo 4: Aguarde a execução
- O workflow possui duas etapas: execução dos testes e publicação do relatório
- Aguarde até que ambas as etapas sejam concluídas (círculos verdes)

### Passo 5: Acesse o relatório de testes
- Após a conclusão, clique no job "publish-report"
- No final da execução, você encontrará uma URL para o GitHub Pages
- A URL será similar a: `https://seu-usuario.github.io/interview_zen/`
- Clique nesse link para visualizar o relatório Allure

## Modificando os testes

### Adicionando novos termos de busca
Edite o arquivo `src/test/java/com/test/agi/utils/TestData.java` e adicione ou descomente os termos desejados:
```java
@DataProvider(name = "termosValidos")
public static Object[][] termosValidos() {
    return new Object[][] {
        {"consignado"},
        {"empréstimo"},
        {"cartão de crédito"},
        {"financiamento"}
    };
}
```

### Adicionando novos cenários de teste
1. Crie um novo método de teste na classe `BuscaTests.java`
2. Utilize as anotações Allure para documentação (@Description, @Severity, @Story)
3. Implemente a lógica de teste usando a classe `BlogPage`

## Solução de problemas

Se o GitHub Actions falhar, verifique:
1. Se as GitHub Pages estão habilitadas (Settings > Pages > Source: GitHub Actions)
2. Se o fork está atualizado com o repositório original
3. Se não existem problemas com permissões no repositório
