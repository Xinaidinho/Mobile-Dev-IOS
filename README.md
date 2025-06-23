# Documentação do Projeto: PokeExplorer

## 1. Descrição Geral do Aplicativo

O PokeExplorer é um aplicativo iOS, desenvolvido nativamente com SwiftUI, que oferece uma experiência completa para fãs de Pokémon. Ele permite que os usuários:

-   **Criem uma conta e façam login**: O acesso ao aplicativo é protegido por um sistema de autenticação. Os dados do usuário são armazenados de forma segura localmente.
-   **Explorem Pokémon**: Os usuários podem navegar por uma grade visualmente atraente de Pokémon, com rolagem infinita para carregar mais criaturas.
-   **Visualizem Detalhes**: Ao selecionar um Pokémon, uma tela de detalhes é exibida, mostrando informações como imagem, tipos, altura e peso.
-   **Gerenciem Favoritos**: Usuários podem adicionar ou remover Pokémon de sua lista de favoritos pessoal. Essa lista é persistida e vinculada à sua conta.
-   **Animações Fluidas**: O aplicativo utiliza animações de transição suaves ao navegar da lista para a tela de detalhes, melhorando a experiência do usuário.

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

O aplicativo decodifica as respostas JSON da API utilizando as seguintes estruturas `Codable` definidas em `Models/API/Pokemon.swift`:

-   **`Pokemon`**: Contém o nome (`name`) e a URL (`url`) para os detalhes.
-   **`PokemonResponse`**: A resposta da lista paginada, contendo a contagem total (`count`) e um array de `results` (`[Pokemon]`).
-   **`PokemonDetail`**: Contém informações detalhadas, incluindo:
    -   `id`: O identificador numérico.
    -   `name`: O nome do Pokémon.
    -   `height` e `weight`: Altura e peso.
    -   `types`: Um array contendo os tipos do Pokémon (ex: "Grass", "Poison").
    -   `sprites`: Um objeto que contém as URLs das imagens. O app utiliza especificamente a `official-artwork`.

---

## 3. Arquitetura do Aplicativo

O projeto adota a arquitetura **MVVM (Model-View-ViewModel)**, aprimorada com uma camada de **Serviços** para separar completamente a lógica de negócios das fontes de dados.

### Diagrama da Arquitetura

```mermaid
graph TD
    subgraph View
        A[LoginView]
        B[PokemonListView]
        C[PokemonDetailView]
        D[FavoritesView]
    end

    subgraph ViewModel
        E[LoginViewModel]
        F[PokemonListViewModel]
        G[PokemonDetailViewModel]
    end

    subgraph Services
        H(APIService)
        I(PersistenceService)
    end

    subgraph Model
        J[API Models: Pokemon, PokemonDetail]
        K[Persistence Models: User, FavoritePokemon]
    end

    subgraph Data Sources
        L(PokéAPI - Rede)
        M(SwiftData - Local DB)
    end

    A --> E
    B --> F
    C --> G
    D -- @Query --> M

    E --> I
    F --> H
    G --> H
    G --> I

    H --> L
    I --> M

    L -- JSON --> J
    H -- Decoded --> J
    J --> F
    J --> G

    I -- Fetched --> K
    K --> E
    K --> G
