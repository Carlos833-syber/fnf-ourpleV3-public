# Ourple V3 no Android

## Gerar o APK pelo site do GitHub

1. Coloque os arquivos deste port no repositorio, mantendo as pastas.
2. Abra **Actions → Build Ourple V3 Android APK → Run workflow → Run workflow**.
3. Aguarde o job terminar. Em **Artifacts**, baixe **OurpleV3-Android-arm64** e extraia o ZIP.
4. Copie `OurpleV3-Android-arm64.apk` para o celular e permita a instalacao pelo app que abrir o arquivo.

O APK suporta Android 6.0 ou posterior em aparelhos ARM64. E uma compilacao para instalacao direta, nao uma publicacao na Play Store. Cada execucao usa uma chave de teste nova: para instalar um APK de outra execucao, pode ser necessario desinstalar o anterior, apagando seus dados. Faca backup antes se quiser preservar o progresso.

## Controles

- Menus: direcional Psych Mobile para navegar; A confirma e B volta.
- Músicas: quatro faixas da hitbox aceitam toques simultâneos e notas sustentadas; P abre a pausa. Options > Controls permite trocar para botões com setas.
- Freeplay: C abre os ajustes de gameplay.
- Teclado e controle fisico continuam disponiveis.

No primeiro inicio, uma tela copia os vídeos, os mods incluídos e os arquivos de texto/Lua para o armazenamento privado do app. Aguarde a porcentagem chegar a 100%. Nao e preciso conceder permissoes de armazenamento nem copiar uma pasta `mods` manualmente. Em atualizacoes com a mesma assinatura, os arquivos incluidos sao atualizados quando o manifesto muda. Mods externos adicionados manualmente nao fazem parte deste instalador.

## Compilar localmente

Use Haxe 4.3.6, Neko, Haxelib, Java 17 e o Android SDK com plataforma 34, build tools 34.0.0 e NDK 21.4.7075529. A partir da raiz:

```sh
haxelib --global install hmm 3.1.0 --always
haxelib --global run hmm install
# Restaure as versoes declaradas apos a instalacao de dependencias transitivas:
python3 - <<'PY'
import json, subprocess
for dep in json.load(open('hmm.json'))['dependencies']:
    if dep['type'] == 'haxelib':
        subprocess.run(['haxelib', 'set', dep['name'], dep['version']], check=True)
PY
(cd .haxelib/hxcpp/git/tools/hxcpp && haxe compile.hxml)
python3 scripts/prepare_android_assets.py
haxelib run lime config ANDROID_SDK "$ANDROID_HOME"
haxelib run lime config ANDROID_NDK_ROOT "$ANDROID_HOME/ndk/21.4.7075529"
haxelib run lime config JAVA_HOME "$JAVA_HOME"
haxelib run lime config ANDROID_SETUP true
haxelib run lime build android -release -arm64
```

O workflow alinha o APK e aplica uma chave de teste para instalacao direta. O modo `-release` otimiza o codigo Haxe nativo; sem um certificado de publicacao, o Lime usa o empacotamento de teste do Android.

## Limites

- Vídeos estão habilitados no Android com hxCodec 2.6.1. São copiados para o armazenamento privado na primeira abertura; a reprodução precisa ser conferida no celular.
- A implementacao Lua foi restaurada do Ourple original (`FixedData/fnf-ourpleV3-public`, commit `9920ba3337447a7ad9635b8d7cc4712c978afeab`), incluindo os helpers usados por eventos Haxe.
- O mod usa texturas grandes e shaders personalizados. Compilar o APK nao comprova desempenho ou compatibilidade grafica em todos os celulares. Teste o menu, uma musica, notas sustentadas, pausa e as fases especiais no seu aparelho.
- Se a compilacao falhar, baixe **OurpleV3-build-logs** e envie `build-release.log`.

## Correção de arquivos vazios

Arquivos como `mods/custom_events/bitebutton.txt` podem estar vazios por definição. O manifesto registra o tamanho de cada arquivo, e o instalador preserva arquivos de zero bytes sem tratá-los como ausentes. Para atualizar um port anterior, substitua juntos `scripts/prepare_android_assets.py` e `source/AndroidBootstrapState.hx`, faça o commit e inicie uma nova execução do workflow.

## Correção do áudio ao confirmar o aviso

No Android, os sons e músicas do APK são carregados pelo registro de recursos do OpenFL, preservando os IDs das bibliotecas. A leitura anterior procurava arquivos de áudio no armazenamento privado, onde esses recursos não foram copiados. O teste nativo no Linux reproduziu a falha anterior e decodificou corretamente os sons de confirmação/cancelamento, título, menu e uma música da biblioteca songs após mudar o diretório de trabalho. A compilação Android com essa correção passou. O teste no celular continua pendente.

## Controles de toque no Android

Os botões de jogo reconhecem os nomes das quatro ações de notas em maiúsculas e minúsculas. Os toques são enviados diretamente à coluna correspondente, independentemente das teclas de teclado salvas. Options > Controls no Android ajusta altura, posição superior/inferior e transparência dos botões. UP/DOWN selecionam, LEFT/RIGHT ajustam valores, OK alterna a posição e BACK volta/salva. Teste notas simultâneas e sustentadas e reabra o aplicativo para conferir os ajustes no celular.

## Hitbox e botões Psych Mobile, imagem 16:9

Android mantém o quadro 1280x720 e usa RatioScaleMode(false), com bordas centralizadas quando necessário. Options > Controls oferece Hitbox (padrão) ou Buttons; Hitbox Style escolhe Gradient, Outline ou Hidden. As quatro faixas cobrem a área do jogo e o botão P tem prioridade sobre a faixa direita. Os menus usam direcional em cruz e botões A/B; C abre configurações no Freeplay. Os oito gráficos originais da Psych Mobile 0.6.3 têm licença e procedência em docs/licenses/.

Compilação Android passou; testes locais cobriram quatro toques simultâneos, hold/release, foco, pausa, bordas, menu e geometria em quatro proporções. OpenFL decodificou os 16 quadros dos botões registrados no pacote. Verificação visual, toque físico e persistência das opções no celular continuam pendentes.

## Vídeos e telas de carregamento

O pacote completo habilita VIDEOS_ALLOWED e NO_PRELOAD_ALL no Android. As 33 imagens em assets/preload/images/loading/ e a animação load.png/load.xml já pertencem ao repositório e são mostradas durante o carregamento. Os vídeos originais de assets/videos/ e o vídeo do mod são copiados para arquivos privados reais: não é necessário criar pasta no armazenamento compartilhado nem conceder acesso geral aos arquivos. A primeira preparação usa aproximadamente 151 MB adicionais para os vídeos originais.

Durante as cutscenes, A pula o vídeo. Os vídeos dentro das músicas acompanham o fluxo do jogo e são interrompidos ao sair da fase. Pause, reprodução, áudio e retorno após pular devem ser testados no aparelho. A compilação ARM64 e os testes de caminhos/arquivos/encerramento locais passaram; não houve teste de reprodução em Android neste ambiente.
