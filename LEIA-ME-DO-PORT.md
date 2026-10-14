# Aplicar o port Android do Ourple V3

Este pacote contem codigo-fonte e configuracao; nao e um APK. As alteracoes ainda nao foram publicadas no seu GitHub.

Repositorio de destino: https://github.com/Carlos833-syber/fnf-ourpleV3-public
Base usada: 58eadd27db64fcead4b41ce4f6dae5b79c68e44c

## Pelo GitHub

1. Extraia `ourple-android-port.zip`.
2. Envie os arquivos para o repositorio, preservando cada caminho. Nao envie o ZIP inteiro esperando que o GitHub extraia. As pastas `.github`, `source` e `scripts` devem continuar com esses nomes.
3. Exclua `.github/workflows/build-mod.yml`: o arquivo anterior nao era um workflow valido.
4. Abra Actions, escolha **Build Ourple V3 Android APK** e clique em **Run workflow**.
5. Se terminar com sucesso, baixe o artifact **OurpleV3-Android-arm64**, extraia e instale o APK no celular.

Consulte `docs/ANDROID.md` para controles, requisitos, assinatura de teste e limites.

## Com Git

Na raiz de um clone do repositorio, com o patch baixado:

```sh
git apply --check /caminho/ourple-android.patch
git apply /caminho/ourple-android.patch
```

Revise as mudancas e publique pelo seu fluxo normal. O patch inclui a remocao do workflow invalido.

## Tudo em um único pacote

Este ZIP reúne as correções de arquivos vazios, áudio, controles, hitbox e botões Psych Mobile, imagem 16:9, vídeos Android e telas de carregamento. Use este pacote atualizado para substituir os arquivos dos pacotes anteriores.

Envie TODO o conteúdo extraído, incluindo source/AndroidVideoHandler.hx, Project.xml, scripts/prepare_android_assets.py, assets/ e .github/. Mantenha os arquivos originais do mod no repositório: os vídeos e as imagens de loading existentes não são duplicados no ZIP de atualização. Faça o commit antes de iniciar uma NOVA execução do workflow.

O pacote é uma atualização do código-fonte, não um APK. O APK completo é grande e deve ser baixado pelos Artifacts do Actions. Durante as cutscenes, A pula. Vídeo, som, loading e retorno ao jogo ainda precisam ser testados no aparelho.
