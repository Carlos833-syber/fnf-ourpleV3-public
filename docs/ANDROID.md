# Ourple V3 no Android

## Gerar o APK pelo site do GitHub

1. Coloque os arquivos deste port no repositorio, mantendo as pastas.
2. Abra **Actions → Build Ourple V3 Android APK → Run workflow → Run workflow**.
3. Aguarde o job terminar. Em **Artifacts**, baixe **OurpleV3-Android-arm64** e extraia o ZIP.
4. Copie `OurpleV3-Android-arm64.apk` para o celular e permita a instalacao pelo app que abrir o arquivo.

O APK suporta Android 6.0 ou posterior em aparelhos ARM64. E uma compilacao para instalacao direta, nao uma publicacao na Play Store. Cada execucao usa uma chave de teste nova: para instalar um APK de outra execucao, pode ser necessario desinstalar o anterior, apagando seus dados. Faca backup antes se quiser preservar o progresso.

## Controles

- Menus: LEFT/DOWN/UP/RIGHT para navegar; OK para confirmar; BACK para voltar.
- Musicas: quatro botoes na parte inferior aceitam toques simultaneos e notas sustentadas; PAUSE abre o menu de pausa.
- Freeplay: SETTINGS abre os ajustes de gameplay.
- Teclado e controle fisico continuam disponiveis.

No primeiro inicio, uma tela copia os mods incluidos e os arquivos de texto/Lua para o armazenamento privado do app. Aguarde a porcentagem chegar a 100%. Nao e preciso conceder permissoes de armazenamento nem copiar uma pasta `mods` manualmente. Em atualizacoes com a mesma assinatura, os arquivos incluidos sao atualizados quando o manifesto muda. Mods externos adicionados manualmente nao fazem parte deste instalador.

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

A compilacao local gera um APK release sem assinatura; o workflow faz o alinhamento e a assinatura para permitir a instalacao.

## Limites

- Videos permanecem desativados no Android; o jogo usa o fluxo alternativo ja existente quando `VIDEOS_ALLOWED` esta ausente.
- A implementacao Lua foi restaurada do Ourple original (`FixedData/fnf-ourpleV3-public`, commit `9920ba3337447a7ad9635b8d7cc4712c978afeab`), incluindo os helpers usados por eventos Haxe.
- O mod usa texturas grandes e shaders personalizados. Compilar o APK nao comprova desempenho ou compatibilidade grafica em todos os celulares. Teste o menu, uma musica, notas sustentadas, pausa e as fases especiais no seu aparelho.
- Se a compilacao falhar, baixe **OurpleV3-build-logs** e envie `build-release.log`.
