# vl_workforce

Workforce IA avancée pour **VoxeLibre / MineClone2** sur **Luanti/Minetest ≥ 5.6**.

## Objectif

- Ajouter des **workers IA** capables de :
  - construire des structures (builder),
  - farmer automatiquement (farmer),
  - miner (miner),
  - défendre une zone (soldier),
  - transporter des ressources (carrier),
  - changer de rôle (foreman).
- Utiliser **le mesh joueur** (`character.b3d`) fourni par VoxeLibre.
- Utiliser les **skins VoxeLibre** via `mcl_skins` (aucun asset dans ce mod).

## Installation

1. Copier le dossier `vl_workforce/` dans le répertoire :
   - `worldmods/` de votre monde VoxeLibre, **ou**
   - `games/VoxeLibre/mods/` pour l'avoir partout.
2. Vérifier que vous lancez bien un jeu basé sur VoxeLibre / MineClone2.
3. Démarrer le monde.

## Commandes principales

- `/vlw_spawn`  
  Fait apparaître un worker près de vous.

- `/vlw_job <idle|builder|farmer|miner|soldier|carrier|foreman|lumberjack|guard>`  
  Change le job du worker que vous regardez.

- `/vlw_ui`  
  Ouvre une petite interface pour changer le job du worker visé.

Les commandes exigent `interact` (ou `server` si vous renforcez les droits).

## Jobs disponibles

- **idle** : Le worker se promène sans but précis.
- **builder** : Construit des structures selon un blueprint (par défaut : une petite cabane).
- **farmer** : Prépare une parcelle 9x9, plante et récolte automatiquement du blé.
- **miner** : Cherche et mine du charbon, du fer et de la pierre aux alentours.
- **soldier** : Patrouille et attaque les entités hostiles à proximité.
- **carrier** : Dépose tous ses items dans le coffre le plus proche puis passe en idle.
- **foreman** : Change automatiquement de job toutes les 30-60 secondes (farmer/miner/builder).
- **lumberjack** : Cherche et coupe des arbres (placeholder, fonctionnel de base).
- **guard** : Patrouille autour d'un point de garde et attaque les hostiles (placeholder).

## Dépendances

- `depends = mcl_core`
- `optional_depends = mcl_skins, mcl_tools, mcl_farming, mcl_chests, mcl_doors, mcl_stairs, mcl_flowers, mcl_mobitems, mcl_mobs`

Le mod fonctionne même si `mcl_skins` est absent : dans ce cas les workers utilisent simplement `character.png`.

## Architecture

- `init.lua` : enregistrement de l'entité worker, boucle logique, commandes.
- `ui.lua` : interface simple pour changer de job.
- `core/` : noyau technique (perception, pathfinding, inventaire, stockage, skins).
- `jobs/` : implémentations des différents métiers.
- `blueprints/` : définitions de structures (hut, farm 9x9, etc.).

Ce mod se veut une base extensible pour aller vers une vraie population de PNJ villageois intelligents.
