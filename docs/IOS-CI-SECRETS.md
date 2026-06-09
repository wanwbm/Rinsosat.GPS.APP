# CI iOS — segredos GitHub Actions

O workflow **Build iOS** (`.github/workflows/build-ios.yml`) tem dois jobs:

| Job | O que faz | Segredos |
|-----|-----------|----------|
| **Compile** | `pod install` + `flutter build ios --no-codesign` | Nenhum |
| **Release** | Assinatura automática + IPA + upload TestFlight | Ver abaixo |

## Segredos obrigatórios (job Release)

Configurar em **Settings → Secrets and variables → Actions** no repositório:

| Segredo | Descrição |
|---------|-----------|
| `ASC_API_KEY_BASE64` | Ficheiro `.p8` da API App Store Connect, codificado em base64 |
| `ASC_KEY_ID` | Key ID da API (ex.: `ABC123XYZ`) |
| `ASC_ISSUER_ID` | Issuer ID da conta Apple Developer |
| `IOS_KEYCHAIN_PASSWORD` | Password temporária para o keychain do runner (qualquer string segura) |
| `IOS_DIST_PRIVATE_KEY` | Chave privada PEM do certificado **Apple Distribution** (texto completo, incluindo `BEGIN/END`) |

## Identificadores do app

- **Bundle ID iOS:** `com.rinosat.app`
- **Team ID (Apple):** `ZQKCNHPLF4` (em `ios/ExportOptions.plist` e Xcode)
- **Firebase:** projecto `rinosat-app`

## Gerar base64 da chave .p8

```bash
base64 -w0 AuthKey_XXXXX.p8
```

## Notas

- O job **Compile** valida código e CocoaPods em cada push — deve passar sem segredos.
- O job **Release** usa `codemagic-cli-tools` para obter perfil e certificado via App Store Connect API (não precisa de `P12_BASE64` manual).
- Workflow **Release** (tags `v*`) usa os mesmos segredos `ASC_*` e `IOS_*`.
