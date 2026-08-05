# Gestão Sítio Vô Augusto - Mobile App

Aplicativo desenvolvido em Flutter para o ecossistema do Gestão Sítio Vô Augusto, focado no gerenciamento de propriedades cafeeiras, talhões, pessoas e finanças agrícolas. O projeto adota uma arquitetura baseada no padrão **MVVM (Model-View-ViewModel)** com gerenciamento de estado via **Provider**.

## Visão Geral da Arquitetura e Estrutura de Pastas

O projeto é separado em camadas para garantir o desacoplamento entre a interface visual, a lógica de apresentação e os modelos de domínio. 

* **`assets/`**: Diretório reservado para imagens, ícones e demais recursos estáticos do aplicativo.

* A estrutura principal fica dentro do diretório `lib/`:
  
* **`http/`**: Camada de comunicação de rede (API do backend).
  * **`services/`**: Métodos de requisição HTTP, centralizando os métodos de recebimento de mensagens de erro.
  * **`exceptions/`**: Exceções programadas a serem recebidas e tratadas pelo sistema.
  * **`dtos/`**: Data Transfer Objects; define como dados específicos (que não são regras de domínio) devem ser enviados ao backend e como são recebidos.
* **`model/`**: Entidades e regras de domínio da aplicação. Contém os modelos necessários para fazer validações corretas, métodos de conversão de envio/recebimento (Mappers) e Factories.
* **`utils/`**: Utilitários globais do sistema.
  * **`validator/`**: Validações de possíveis inputs para retornar erros precisos ao usuário.
  * **`masks/`**: Formatações para melhorar a experiência do usuário (limite de caracteres, formatação de telefone com DDD, pontuação de CPF/CNPJ, etc.).
* **`viewmodels/`**: Camada de mediação. Faz a comunicação com os serviços (HTTP) e contém a lógica que alimenta as Views.
* **`views/`**: Camada de interface (Frontend puro em Flutter). Responsável por desenhar a tela e consumir os dados das ViewModels.
* **`widgets/`**: Componentes visuais criados para serem reaproveitados em diversas telas, reduzindo a duplicação de código.

## Requisitos e Configuração do Ambiente (Execução)

### Pré-requisitos
* **Flutter SDK**: Versão estável instalada e configurada.
* **VS Code**: Editor de código utilizado.
* **Android Studio**: IDE recomendada para simular o uso do aplicativo.

> **⚠️ Atenção sobre a Execução:** 
> Para executar e testar o Flutter corretamente neste projeto, é **obrigatório** utilizar um emulador de telefone (como Virtual Device Manager do Android Studio) ou um dispositivo físico. Isso é necessário para o correto funcionamento dos cookies e da sessão, visto que o comportamento na web difere da arquitetura mobile implementada.

## Como Executar o Projeto

1. **Clonar o repositório:**
   ```bash
   git clone [https://github.com/heitorPoleze/frond_end_cafeicultura_mobile.git](https://github.com/heitorPoleze/frond_end_cafeicultura_mobile.git)
   cd frond_end_cafeicultura_mobile

2. **Instalar as dependências:**   
  ```bash
   flutter pub get
  ```


3. **Iniciar o emulador:**   
> Abra o Android Studio e inicie o seu emulador (Virtual Device). Certifique-se de que ele está online e que o VS Code o reconhece.


4. **Rodar a aplicação:**   
  ```bash
   git checkout develop
   flutter run
```

## Fluxo de Trabalho (Git Flow)
* Adotamos o modelo Git Flow para o controle de versão e organização do desenvolvimento
* **main:** Código em produção (estável).
* **develop:** IDE recomendada para simular o uso do aplicativo.
* **feature/...:** Branches criadas a partir da **develop:** para desenvolvimento de novas funcionalidades.
* **fix/...:** Branches destinadas à correção de bugs.


## Integrações e Links Úteis
* Toda a comunicação HTTP é feita com o repositório de backend:
```bash https://github.com/heitorPoleze/backend_cafeicultura

* Consulte o repositório do backend para acessar a documentação detalhada da API, rotas e payloads esperados.
