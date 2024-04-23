

# The Mythril RPG
Mythril has been an elusive game design that has had it's development destroyed by scope creep at every turn. It's an attempt to capture an experience that other video games just don't have. 

## The Experience
- A dungeon master creates a vast world for their players to become immersed in. 
- A player get's lost in an epic story.
- A team of player's must strategize their resources in order to defeat a challenging enemy.

### Data
NO DATABASES!!
All persistence will live in a player's JSON save file. The content will be 100% reactive to that state.

### Network
- Support the three network modes = host, server, client. 
- Use Godot's built-in multiplayer sync. 
- One-Room design. No channels
- No authentication layer. OUT OF SCOPE! -- Just like DND, this should be like inviting someone to your house. Security & Authorization can be handled on the host machine. 

## Development Phase
Each named phase will adhere to the following development cycle:
1. Prior to all requirements being met, work will be done on branch: {phase_name}n.x
2. As soon as initial requirements are met, promote branch to {phase_name}n.0
4. If all bugs get fixed, the projected is promoted into the next named phase or version.

- [[Design]]
	 This doc. 
- [[Prototype]]
	Not all required features to reach MVP for players but enough for content creators to start creating.
- [[Alpha]]
	The bare minimum required for the game to function 
- [[Beta]]
	All planned features implemented plus a launcher
- [[Release]]
	Polished, bug fixes, and packaged for users.