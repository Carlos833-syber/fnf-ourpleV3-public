# Ourple V3 — correção de abertura (versão sem vídeos)

Aplique sobre o port Android que já tem os controles Psych Mobile e as correções de áudio/arquivos vazios.

1. Extraia este ZIP. Envie todos os arquivos de source/, assets/ e docs/ ao repositório Carlos833-syber/fnf-ourpleV3-public, mantendo os caminhos e substituindo os arquivos existentes.
2. Faça o commit e inicie uma NOVA execução em Actions > Run workflow. Reexecutar um build antigo usa o commit antigo.
3. Baixe e instale o novo APK gerado.

O pacote protege o carregamento dos gráficos dos botões: se uma imagem estiver ausente ou não puder ser decodificada, usa botões simples que continuam funcionando. Os controles aguardam o fim da preparação dos arquivos para carregar as imagens. Também adiciona uma mensagem para erros Haxe capturados, com registro privado last-error.txt.

Se continuar travando ou ficar preto, envie a captura da mensagem “Ourple V3 - erro” e o modelo do celular. Se não aparecer mensagem, informe isso também: falhas nativas ou encerramentos pelo Android podem não ser capturados.

A causa da falha no seu aparelho ainda não foi confirmada. A compilação Android ARM64 e os testes locais de imagens ausentes/nulas/inválidas, falha de decodificação e controles passaram. Ainda falta testar a abertura no celular.

Este pacote não adiciona vídeos. A licença e a origem dos oito gráficos estão em docs/licenses/.
