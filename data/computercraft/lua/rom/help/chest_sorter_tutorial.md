# Chest Sorter Tutorial

## Overview
The Chest Sorter program allows you to automatically sort items from an input chest into different output chests based on categories you define. This tutorial will guide you through setting up and using the program.

## Required Materials
- 1 Computer (any tier)
- 1 Comparator
- At least 2 Chests (more recommended for better organization)
- Redstone dust (for connections)
- Items to sort (coal, iron ore, tools, etc.)

## Hardware Setup
1. Place the computer on the ground.
2. Place the comparator next to the computer.
3. Connect the comparator to all chests you want to use:
   - Input chest (where you'll place items to sort)
   - Output chests (for different categories)
4. Ensure all chests are within 12 blocks of the comparator for wireless connection.
   - Alternatively, use redstone cables to connect chests further away.

## Program Installation
The Chest Sorter program is included in LeonOS. To access it:
1. Turn on the computer.
2. Type `chest_sorter` and press Enter to run the program.

## First Time Setup Wizard
When you run the program for the first time, you'll go through a setup wizard:

1. **Select Input Chest**:
   - The program will list all connected chests.
   - Enter the number corresponding to the chest you want to use as input.

2. **Assign Output Chests**:
   - For each remaining chest, you'll be prompted to assign a category.
   - Enter a descriptive category name (e.g., 'coal', 'tools', 'food').
   - Type 'done' when you've assigned all desired categories.

3. **Configuration Saved**:
   - Your settings will be saved to `/chest_sorter_config.json`.
   - You can re-run the setup by deleting this file.

## Using the Program
1. After setup, the program will start automatically sorting items.
2. Place items in the input chest.
3. The program will:
   - Detect items in the input chest
   - Identify the appropriate category based on item name
   - Move the item to the corresponding output chest
4. Press `Ctrl+T` to stop the program.

## Category Matching Rules
The program matches items to categories using simple string matching:
- It checks if the category name appears in the item's internal name or display name
- Example: A category named 'coal' will match 'minecraft:coal' and 'minecraft:charcoal'
- Example: A category named 'tool' will match 'minecraft:iron_pickaxe' and 'minecraft:gold_axe'

## Best Practices
- Use specific category names for better sorting (e.g., 'iron_ore' instead of 'ore')
- Create separate categories for similar items (e.g., 'swords', 'pickaxes')
- Label your output chests physically to remember which category is which
- Regularly empty output chests to prevent them from becoming full

## Troubleshooting
- **No chests detected**:
  - Check that all chests are properly connected to the comparator
  - Ensure the comparator is connected to the computer

- **Items not sorting correctly**:
  - Check that category names match item names appropriately
  - Verify that output chests are not full

- **Program stops unexpectedly**:
  - Check the computer's fuel level (for advanced computers)
  - Make sure no redstone signal is interrupting the computer

## Running the Tutorial In-Game
You can view this tutorial in-game by running:
```
chest_sorter tutorial
```

## Example Setup
Here's an example of a good setup:
- Input chest: chest_0
- Output chests:
  - 'coal': chest_1
  - 'iron': chest_2
  - 'tools': chest_3
  - 'food': chest_4

This would sort all coal-related items to chest_1, iron-related items to chest_2, etc.

Happy sorting!