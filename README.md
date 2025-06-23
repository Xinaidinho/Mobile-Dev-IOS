# Documentação do Projeto: PokeExplorer

## 1. Descrição Geral do Aplicativo

O PokeExplorer é um aplicativo iOS, desenvolvido nativamente com SwiftUI, que oferece uma experiência completa para fãs de Pokémon. Ele permite que os usuários:

-   **Criem uma conta e façam login**: O acesso ao aplicativo é protegido por um sistema de autenticação. Os dados do usuário são armazenados de forma segura localmente.
-   **Explorem Pokémon**: Os usuários podem navegar por uma grade visualmente atraente de Pokémon, com rolagem infinita para carregar mais criaturas.
-   **Visualizem Detalhes**: Ao selecionar um Pokémon, uma tela de detalhes é exibida, mostrando informações como imagem, tipos, altura e peso.
-   **Gerenciem Favoritos**: Usuários podem adicionar ou remover Pokémon de sua lista de favoritos pessoal. Essa lista é persistida e vinculada à sua conta.

O projeto é construído com tecnologias modernas da Apple, incluindo Swift, SwiftUI para a interface, e SwiftData para a persistência de dados local.

---

## 2. Escolha da API: PokéAPI

O aplicativo utiliza a [PokéAPI](https://pokeapi.co/) como fonte de dados para todas as informações relacionadas aos Pokémon.

### Justificativa da Escolha

A PokéAPI foi escolhida pelos seguintes motivos:

-   **Gratuita e Aberta**: É uma API de uso gratuito que não requer chaves de autenticação, facilitando o desenvolvimento e o aprendizado.
-   **Documentação Completa**: Possui uma documentação rica e detalhada, o que agiliza a consulta de endpoints e a modelagem dos dados.
-   **Dados Abrangentes**: Oferece uma vasta quantidade de dados sobre o universo Pokémon, ideal para a proposta do aplicativo.
-   **Foco Educacional**: A própria API se posiciona como uma ferramenta educacional, alinhando-se ao propósito de projetos de aprendizado e portfólio.

### Como a API é Utilizada

A interação com a API é centralizada no `APIService.swift`. Este serviço utiliza `async/await` para realizar chamadas de rede de forma assíncrona.

-   **Listagem de Pokémon**: Para buscar a lista de Pokémon, o app faz uma requisição `GET` ao endpoint `/api/v2/pokemon`. A paginação é controlada pelos query parameters `limit` e `offset`, permitindo carregar os Pokémon em lotes.
-   **Detalhes do Pokémon**: Para obter os detalhes de um Pokémon específico, o app utiliza a URL fornecida para cada Pokémon na resposta da listagem, fazendo uma nova requisição `GET` a essa URL.

### Dados Utilizados

O aplicativo decodifica as respostas JSON da API utilizando as estruturas `Codable` definidas em `Models/API/Pokemon.swift`:

-   **`Pokemon`**: Contém o nome (`name`) e a URL (`url`) para os detalhes.
-   **`PokemonResponse`**: A resposta da lista paginada, contendo a contagem total (`count`) e um array de `results` (`[Pokemon]`).
-   **`PokemonDetail`**: Contém informações detalhadas, incluindo:
    -   `id`: O identificador numérico.
    -   `name`: O nome do Pokémon.
    -   `height` e `weight`: Altura e peso.
    -   `types`: Um array contendo os tipos do Pokémon.
    -   `sprites`: Um objeto que contém as URLs das imagens. O app utiliza especificamente a `official-artwork`.

---

## 3. Arquitetura do Aplicativo

O projeto adota a arquitetura **MVVM (Model-View-ViewModel)**, aprimorada com uma camada de **Serviços** para separar completamente a lógica de negócios das fontes de dados.

### Descrição das Camadas

1.  **View**: Composta por estruturas SwiftUI (`Views/**/*.swift`). É a camada de apresentação, responsável por exibir os dados e capturar as interações do usuário. Ela observa as mudanças no ViewModel para se atualizar e invoca suas funções em resposta a eventos (como toques em botões).
2.  **ViewModel**: Responsável pela lógica de apresentação (`ViewModels/**/*.swift`). Ele prepara os dados do Model para serem exibidos pela View e contém o estado da UI (ex: `isLoading`, `errorMessage`). Ele não tem conhecimento direto sobre a View nem sobre como os dados são obtidos, apenas se comunica com a camada de Serviço através de protocolos.
3.  **Service**: Camada que abstrai as fontes de dados (`Services/*.swift`). O `APIService` lida com as chamadas de rede, enquanto o `PersistenceService` gerencia as operações do banco de dados local. Essa separação permite que os ViewModels sejam testados de forma isolada, injetando "mocks" (serviços falsos) dos serviços.
4.  **Model**: Representa os dados da aplicação (`Models/**/*.swift`). Está dividido em modelos de API (dados da rede) e modelos de persistência (esquema do banco de dados SwiftData).

---

## 4. Implementação do SwiftData

O aplicativo utiliza **SwiftData** para persistência de dados local, como informações de usuários e seus Pokémon favoritos.

### Modelo de Dados

O esquema do banco de dados é definido por dois modelos em `Models/Persistence/`:

-   **`User.swift`**:
    -   `@Model`: Define a classe como um modelo do SwiftData.
    -   `@Attribute(.unique) var username: String`: Garante que cada nome de usuário seja único no banco de dados.
    -   `passwordHash: String`: Armazena o hash da senha do usuário para segurança.
    -   `@Relationship(deleteRule: .cascade)`: Define uma relação um-para-muitos com `FavoritePokemon`. Se um usuário for deletado, todos os seus favoritos associados também serão removidos.

-   **`FavoritePokemon.swift`**:
    -   `@Attribute(.unique) var pokemonID: Int`: Usa o ID do Pokémon da API como chave primária para evitar que o mesmo Pokémon seja favoritado mais de uma vez.
    -   `user: User?`: Define a relação inversa, indicando a qual usuário o favorito pertence.

### Salvando e Buscando Dados

Toda a interação com o SwiftData é encapsulada no `PersistenceService.swift` para manter o código organizado e testável.

-   **Configuração**: O `ModelContainer` é criado na inicialização do app (`PokeExplorerApp.swift`) e injetado no ambiente do SwiftUI, tornando-o acessível em toda a aplicação.
-   **Busca (Fetch)**: Para buscar dados, o serviço utiliza um `FetchDescriptor`, que permite especificar um predicado (`#Predicate`) para filtrar os resultados.
-   **Salvamento (Save)**: Para salvar um novo objeto, ele é inserido no `ModelContext` e, em seguida, o método `save()` é chamado.

### Implementação da Autenticação

A autenticação é um processo de duas etapas gerenciado pelo `PersistenceService`:

1.  **Cadastro (`signUp`)**:
    -   Verifica se o `username` já existe usando um `FetchDescriptor`.
    -   Se não existir, a senha fornecida é transformada em um hash seguro usando `PasswordHasher.hash(password)`.
    -   Um novo objeto `User` é criado com o hash da senha e inserido no SwiftData.

2.  **Login (`login`)**:
    -   Busca o usuário pelo `username`.
    -   Se o usuário for encontrado, a senha fornecida é comparada com o hash armazenado usando `PasswordHasher.verify(password, against: user.passwordHash)`.
    -   Se a verificação for bem-sucedida, o objeto `User` é retornado; caso contrário, um erro é lançado.

---

## 5. Implementação dos Design Tokens

Para garantir consistência visual e facilitar a manutenção do design, o aplicativo utiliza um sistema de **Design Tokens**.

### Definição

Os tokens são definidos como `enum` com propriedades estáticas no arquivo `Design/AppTokens.swift`. Isso centraliza todas as constantes de design em um único local. As categorias de tokens são:

-   `AppColors`: Cores principais, que referenciam o `Assets.xcassets`.
-   `AppFonts`: Estilos de fonte padronizados (título, corpo, legenda).
-   `AppSpacing`: Valores de espaçamento para `padding` e margens.
-   `AppCornerRadius`: Raios de borda para cantos arredondados.

### Uso nas Views

Nas views SwiftUI, esses tokens são usados em vez de valores "mágicos" (hardcoded). Isso torna o código mais legível e permite que uma mudança no token se reflita em todo o aplicativo.

---

## 6. Implementação do Item de Criatividade

O principal item de criatividade implementado no projeto é a **animação de transição compartilhada** entre a tela de lista (`PokemonListView`) e a tela de detalhes (`PokemonDetailView`).

### `matchedGeometryEffect`

-   **Como funciona**: O aplicativo utiliza o modificador `.matchedGeometryEffect()` do SwiftUI para criar uma animação fluida. O card do Pokémon na grade e a imagem principal na tela de detalhes compartilham o mesmo identificador e namespace de animação.
-   **Implementação**:
    1.  Um `@Namespace` é criado na `PokemonListView` e passado para a `PokemonDetailView`.
    2.  Na `PokemonGridItemView` (o card da lista), o modificador é aplicado à imagem do Pokémon.
    3.  Na `PokemonDetailView`, o mesmo modificador é aplicado à imagem principal do Pokémon.

-   **Resultado**: Quando o usuário toca em um Pokémon, o SwiftUI anima a transição da imagem do card, movendo-a e redimensionando-a suavemente para sua posição final na tela de detalhes. Isso cria uma experiência de usuário mais polida e profissional, conectando visualmente as duas telas.

---

## 7. Lista de Bibliotecas de Terceiros

O projeto **não utiliza bibliotecas de terceiros**.

Toda a funcionalidade é construída utilizando exclusivamente frameworks nativos da Apple:

-   **SwiftUI**: Para a camada de interface do usuário.
-   **SwiftData**: Para a persistência de dados.
-   **Foundation**: Para tipos de dados básicos e funcionalidades de rede (`URLSession`).
-   **CryptoKit**: Para o hashing seguro de senhas.
-   **XCTest**: Para os testes de unidade.
