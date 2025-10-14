### Tipos de Commit

| Tipo         | Uso                                                 | Exemplo                                                  |
| ------------ | --------------------------------------------------- | -------------------------------------------------------- |
| **feat**     | Nova funcionalidade.                                | `feat(#11): adicionar upload de imagem`                  |
| **fix**      | Correção de bug.                                    | `fix(#32): corrigir erro de cálculo no carrinho`         |
| **docs**     | Alterações na documentação.                         | `docs(#10): atualizar README`                            |
| **style**    | Formatação, espaçamento, nomes, sem mudança lógica. | `style: padronizar identação`                            |
| **refactor** | Alteração interna sem mudar comportamento.          | `refactor(#21): simplificar middleware de login`         |
| **perf**     | Melhorias de performance.                           | `perf(#8): reduzir tempo de resposta do endpoint /users` |
| **test**     | Testes novos ou modificados.                        | `test(#54): adicionar testes unitários de pagamento`     |
| **chore**    | Manutenção, scripts, dependências.                  | `chore: atualizar dependências do projeto`               |
| **build**    | Mudanças no processo de build, Docker, Vercel, etc. | `build: corrigir build para ambiente de produção`        |
| **ci**       | Mudanças em pipelines ou GitHub Actions.            | `ci: corrigir workflow de deploy`                        |
|              |                                                     |                                                          |
### Branchs para criar
| Tipo de branch | Padrão                     | Exemplo                    |
| -------------- | -------------------------- | -------------------------- |
| **feature**    | `feat/<nome>-#<issue>`     | `feat/login-system-#42`    |
| **bugfix**     | `fix/<nome>-#<issue>`      | `fix/discount-calc-#108`   |
| **refactor**   | `refactor/<nome>-#<issue>` | `refactor/auth-module-#73` |
| **hotfix**     | `hotfix/<nome>`            | `hotfix/payment-failure`   |
| **release**    | `release/vX.Y.Z`           | `release/v1.3.0`           |
### Modelo
```
<tipo>(#<issue>): <resumo curto>

[descrição detalhada - opcional]

Fixes: #<issue>
Refs: #<issue>
```
### Exemplo
```
feat(#42): adicionar autenticação com JWT

Implementado endpoint /auth/login com validação e geração de token JWT.
Atualizados testes e documentação.

Fixes: #42
```
### Processo
- Cria branch
	git switch -c feat/payment-gateway-#56
- Faz mudanças
	git add .
	git commit
- Mensagem gerada:
```
	feat(#56): adicionar integração com gateway de pagamento
	
	Adicionado módulo Stripe.
	Atualizada config e documentação.
	
	Fixes: #56
```
- Push e PR
	git push origin feat/payment-gateway-#56
