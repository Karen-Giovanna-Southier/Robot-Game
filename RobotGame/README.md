# BallGame - Projeto Godot 4

## Como abrir no Godot

1. Abra o Godot 4
2. No Project Manager clique em **Import**
3. Navegue até a pasta `BallGame`
4. Selecione o arquivo `project.godot`
5. Clique em **Import & Edit**

## Estrutura do projeto

```
BallGame/
├── project.godot          ← configuração do projeto
├── scenes/
│   ├── main.tscn          ← cena principal (rode esta)
│   └── ball.tscn          ← cena da bola
└── scripts/
    ├── ball.gd            ← movimento + efeitos da bola
    ├── object_base.gd     ← comportamento de todos os objetos
    ├── spawner.gd         ← spawn aleatório sem sobreposição
    ├── difficulty_timer.gd← dificuldade progressiva
    └── main.gd            ← controla pontuação, game over, UI
```

## Controles

- **Setas do teclado** → mover a bola

## Objetos e efeitos

| Objeto  | Cor       | Efeito na bola           | Pontos |
|---------|-----------|--------------------------|--------|
| Estrela | Amarelo   | Nenhum (coletar pontos)  | +10    |
| Bomba   | Preto     | Game Over                | -50    |
| Gelo    | Azul claro| Diminui velocidade (4s)  | +5     |
| Fogo    | Laranja   | Aumenta velocidade (4s)  | +5     |
| Lama    | Marrom    | Velocidade muito baixa   | 0      |
| Vento   | Verde     | Velocidade levemente alta| +5     |
| Imã     | Roxo      | Efeito visual (3s)       | +8     |

## Sistema de dificuldade

A cada **15 segundos** o nível sobe:
- Nível 1 → +2 objetos, +1 bomba
- Nível 2 → +4 objetos, +2 bombas
- ... e assim por diante até nível 10

## Como adicionar sons

1. Coloque arquivos `.ogg` ou `.wav` na pasta do projeto
2. Na cena `main.tscn`, selecione o nó `SFX/Collect`
3. No Inspector, arraste seu arquivo de som para o campo `Stream`
4. Repita para `SFX/Bomb`
