# Corrigir o erro de arquivo vazio do Ourple

O arquivo mods/custom_events/bitebutton.txt existe no APK e está vazio. O Lime retorna null ao ler arquivos de zero bytes. Este ajuste preserva os arquivos vazios e mantém o erro para falhas de leitura de arquivos não vazios.

1. Extraia este ZIP.
2. No GitHub, substitua OS DOIS arquivos, mantendo os caminhos:
   - scripts/prepare_android_assets.py
   - source/AndroidBootstrapState.hx
3. Faça o commit e inicie uma NOVA execução em Actions → Build Ourple V3 Android APK → Run workflow. Reexecutar o build antigo não usa o commit corrigido.
4. Baixe e instale o novo APK do artefato OurpleV3-Android-arm64. Teste a primeira abertura.

O workflow utiliza uma chave de teste diferente por execução; instalar outro build pode exigir desinstalar o anterior, apagando seus dados.

A compilação Android local e o teste da leitura de arquivos vazios pela API nativa do Lime passaram. Ainda é necessário confirmar a abertura do APK corrigido no celular. Nenhuma alteração foi enviada ao GitHub pelo agente.
