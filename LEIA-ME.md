# Ourple V3: controles Psych Mobile e proporção 16:9

## Instalação

1. Extraia este ZIP e envie TODO o conteúdo das pastas source/, assets/ e docs/ ao repositório Carlos833-syber/fnf-ourpleV3-public, mantendo os caminhos. Substitua os arquivos existentes.
2. Faça o commit. Inicie uma NOVA execução em Actions > Run workflow; reexecutar um build antigo usa o commit antigo.
3. Instale o APK gerado. Mantenha aplicadas as correções anteriores de áudio e arquivos vazios. Este pacote já inclui a correção anterior dos controles de toque.

## Controles

- Menu: direcional em cruz; A confirma e B volta. C abre Options no Freeplay. P pausa durante a música.
- Options > Controls > Control Mode: Hitbox usa quatro faixas verticais cobrindo a área do jogo, da esquerda para a direita: esquerda, baixo, cima, direita. Buttons usa quatro botões com setas.
- Hitbox Style: Gradient, Outline ou Hidden. As faixas só aparecem quando tocadas; Hidden não mostra o toque.
- Button Opacity controla a transparência dos botões e da resposta da hitbox.
- Button Height e Buttons at Top ajustam os botões da música no modo Buttons.
- Use cima/baixo para selecionar, esquerda/direita para ajustar valores e A para alternar a posição. B volta e salva.

O jogo mantém o quadro 1280x720 (16:9), centralizado. Celulares mais largos mostram duas bordas pretas iguais; telas 16:9 não precisam de bordas. Os botões ficam dentro da área do jogo e as bordas não acionam notas.

Os gráficos vêm da Psych Engine Mobile 0.6.3; a licença e os créditos estão em docs/licenses/.

## Verificação

Compilação Android ARM64 concluída. Testes de quatro toques, notas sustentadas, pausa, botões de menu e cálculo de proporção passaram em ambiente local; os 16 quadros dos botões foram decodificados pela biblioteca OpenFL. Esses testes não substituem o teste no celular: confira o menu, uma música, pausa e a persistência das opções.
