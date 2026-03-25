# Splitfoot

Divida times de forma justa, rápida e inteligente.

---

## Sobre o projeto

O **Splitfoot** é um aplicativo criado para resolver um problema comum em partidas amadoras: a divisão equilibrada de times.

Voltado para jogadores casuais, organizadores de peladas e times amadores, o app automatiza a criação de equipes com base em atributos simples e posições dos jogadores.

---

## Problema

- Times desbalanceados prejudicam a partida
- Discussões frequentes na divisão dos times
- Dificuldade em avaliar o nível dos jogadores

---

## Solução

O Splitfoot permite cadastrar jogadores com base em:

- Posição
- Ataque (0–99)
- Defesa (0–99)
- Fôlego (0–99)

A partir dessas informações, o app gera automaticamente times equilibrados, considerando tanto os atributos quanto a distribuição por posição.

---

## Funcionalidades

- Cadastro de jogadores por esporte
- Suporte a futsal, futebol 7 e futebol 11
- Sistema de balanceamento automático
- Três algoritmos diferentes de divisão de times
- Geração de múltiplas opções de escalação
- Busca de jogadores por nome
- Filtro por posição e esporte
- Edição de jogadores
- Validações:
    - Atributos entre 0 e 99
    - Nomes únicos por esporte

---

## Como usar

1. Cadastre os jogadores
2. Defina os atributos (ataque, defesa e fôlego)
3. Escolha o esporte
4. Selecione os jogadores para a partida
5. Gere os times

---

## Tecnologias utilizadas

- Flutter
- Dart
- Hive (persistência local)
- Arquitetura em camadas (Data, UI, Services)

---
## Autor

Desenvolvido por João Lobler  
https://github.com/jalobler7

---

## Motivação

O Splitfoot nasceu para resolver uma dor real: tornar a divisão de times mais justa e eliminar discussões antes das partidas.