# Rinosat GPS Manager — alterações feitas

## O que foi mudado
- Nome da app: "Rinosat GPS" (Android label + iOS CFBundleDisplayName)
- Package/Bundle ID: `org.rinosatapp.manager` (Android applicationId/namespace, iOS PRODUCT_BUNDLE_IDENTIFIER, deep-link scheme)
- Conexão Automática: a app agora migra automaticamente qualquer URL antigo para `https://app.rinosat.com/painel` e adiciona `https://` se faltar.
- Redirecionamentos: permitida a navegação interna em qualquer subdomínio de `rinosat.com`, evitando que a app abra o browser externo em redirecionamentos de login.
- Ecrã de Erro: remodelado para ser mais simples, sem campo de URL visível por padrão e sem referências a marcas externas.
- Rebranding Completo:
  - Nome do projeto Flutter alterado para `rinosat_manager`.
  - Package Android alterado para `org.rinosatapp.manager`.
  - Removidas todas as referências a "Traccar" no código interno (JavaScript bridge, metadados).
- Ícone: gerado a partir do logo enviado, para todos os tamanhos Android e iOS.
- `android/app/google-services.json`: colocado (client Android correspondente a `org.rinosatapp.manager`)
- `lib/firebase_options.dart`: bloco Android atualizado com os dados reais do Firebase (rinosat-app)
- Keystore de assinatura Android criada em `android/app/rinosat-release.keystore`, com `environment/key.properties` a apontar para ela (password gerada aleatoriamente — ver mensagem do chat, guarda-a num gestor de password; sem ela não consegues voltar a assinar atualizações desta app na Play Store)
- `.gitignore` atualizado para nunca subires a keystore nem os ficheiros do Firebase para o GitHub

## PENDENTE — precisa da tua ação
1. **iOS Firebase**: não existe nenhum app iOS registado no Firebase para `org.rinosatapp.manager` (o `GoogleService-Info.plist` que enviaste é do bundle `com.rinosat.app`, que é outra app). Vai à Firebase Console → Adicionar app → iOS → bundle ID `org.rinosatapp.manager`, descarrega o `GoogleService-Info.plist` gerado e envia-mo para eu terminar a configuração (`lib/firebase_options.dart` bloco `ios` e `ios/Runner/GoogleService-Info.plist` ainda têm os valores placeholder antigos).
2. **Build**: este ambiente não tem o Flutter SDK nem o Xcode, por isso não consigo compilar o APK/IPA aqui. Faz o build localmente ou no teu servidor com Flutter instalado:
   ```
   flutter pub get
   flutter build apk --release      # Android
   flutter build ipa --release      # iOS (precisa de macOS + Xcode + conta Apple Developer)
   ```
