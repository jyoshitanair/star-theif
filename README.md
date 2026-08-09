# STAR THEIF!

##### A 2 player multiplayer card game inspired by UNO and Poker!

---

### Contents

* [Access](#access)


* [Description](#description)


* [How to play?](#how-to-play)


* [Features](#features)


* [Ai Usage](#ai-usage)


* [Learning](#learning)


* [Credits](#credits)

* [Screenshots](#screenshots)

## ACCESS

---
* **Github Repo:** https://github.com/jyoshitanair/star-theif

* **Itch.io:** https://jyoshitanair.itch.io/test
(playable in browser! no downloads!)

	#### Note:
	It takes time to connect to the game and leave the game! Please give it some time to connect
	the first time and once a player leaves it takes usually 20 seconds to a minute for it to register 
	that the room is open again! 

	
## DESCRIPTION
#### Creation Details
---
* by: **jyoshitanair** (github)


* project name: **STAR THEIF!** 


* made in: **Godot** Version 4.7 Stable GD script


* exported and playable in *itch.io*


#### Quick Overview
---
This is a game super inspired by Poker and Uno. It is a 2 player multiplayer card game
where you take turns placing cards of the same color/number in the center. Every time you play 
a card you get one point. If you are unable to play a card, you can also switch out one of your
card for a new card!

There are also two special cards. A STAR card which allows you to see the other players deck and a 
THEIF! card which allows you to STEAL a card from another players deck! Hence the name STAR THEIF!

You keep playing for 10 turns and at the end of the game you can also get additional points based on your
hand of 5 cards - like in poker! There are lots of differnt hands you can play that give you a point
boost that ranges from 1 - 14 points!

## HOW TO PLAY
* If this is your first time then read the rules!
* First Create a Room.
* Then find a friend to play with and have them Join the room.
* Once both players are in , the host, player 1, will be prompted to start with the first move
* Keep taking turns playing until eventually 10 turns have passed!
* From here you can play another game or stop :D
* As of now you can click the button to play another game but if you leave and join again it most likely will not work! :D

#### HOW TO WIN

* You need to accumulate the most points!

#### HOW TO LOSE

* If you have less points than the other player - you will loose :,(

## FEATURES
---
* **Multiplayer Game!:**
1) Waoohhh so cool! This was my first time every setting up a multiplayer game
2) It utilizes render to host it, and godot's built in WebRTC / Peer - Peer.
3) All of the configuration files ARE fully written by ai :D This means the network file and the JS config file
4) I did edit them a little bit for readability and had to constantly tweak it whenever I needed changes!
5) New changes to my file are automatically synced by Render which is connected to this git repo!
---
* **Using RPC!:**
1) This is a way to send data over the internet so that some variables that both players needed could be synced!
2) I used this a LOT and its such a cool feature!
---
* **Player Scenes:**	
1) A feature I'm pretty proud about is how I managed to sync data between the player secenes.
2) This was especially hard with race conditions and especially the theif card!
3) You are allowed to see your cards, but the other player is represented by the back of the cards!
4) You can also hoover over the cards as a visual indicator of what you are about to choose!
5) You can also switch your cards if you are unable to place anything!
6) As you can see there are a LOT of different outcomes that can come based on what card is clicked and it's all handled using states in my card.gd script!
---
* **Join/Invite Menu!:**	
1) Invite
	-	Randomly generates a 6 digit code from this allowed set of characters 
	"A","B","C","D","E","F","G","H","J","K","L","M",
	"N","P","Q","R","S","T","U","V","W","X","Y","Z",
	"2","3","4","5","6","7","8","9"
	This is so that characters that can easily be confused like 1 and I are ommited!
	-	Joining and creating a room are handled seperatly!
	-	Utilizes Render!
	- 	Takes a while to set up if it's the first time it's being used in 15 minutes however.
2) Join
	- Utilizes render
	- Provides feedback from the Network global file such as if it's connecting right now or the reason a code was rejected!
	- Remember it takes a while to register that a player has left!
---
* **End:**
- It utilizes an object to register things like the same max color in a row or number
- I did use AI to help figure out how to calculate the max color/ number and I've actually never used objects in Godot lol T-T will definetly be using this a lot!
- Over all it calculates what your best hand is based on the set of cards you had at the end and adds that with the points that you get for placing cards!
---
* **Musicr:**
- It plays music using an autoload :D
---

## AI USAGE: 
* The contents in the Network.gd file and all the Javascript code is FULLY written by AI and tweaked by me :D. 
* ChatGPT and Gemini for debugging, for example:
	- Figuring out how to calculate max color/ number
	- Struggling with race conditions
	- Debugging the theif card state because it greatly deviated from my general flow
	- Learning how to use RPC and WebRTC :D Wow I learned a lot. 
	- and just general debugging !
* But in the end all code and core concepts are written authentically by me (except for what I mentioned)!
* All the art is done by me (<3 i hope you likee itt) and the music is not AI generated lol
* And of course this read me is written by the one and only me :D

## LEARNING:
	
#### *After all after literally spending 30+ hours on this I must have learned something right?*


### Learned:
---
1) What I'm most excited about was being able to learn Multiplayer games. I've always found it daunting and I'm so glad I'm a bit more familiar with it! I hope in the future I'll be able to write my own Network autoload and JS config file!
2) I learned about RPC and how to send data across multiple devices running the same code!
3) More about using a Global file - such as the getter and setter functions when trying to find by variables.
4) I learned how to use transitions to make simple animations like the bounce at the start, (and pivot offset the center too!)
5) And overall I'd say I definetly used a lot more states and Manager variables which I feel way more comforable with!

### Struggles :
	
---
1) **The Theif Card.** AAH I literally thought this was going to be super easy because I was able to get the STAR state done in a hour or two. But no. Everytime I tried to fix it something else 
would break and in the end I had to change the structure of how everything worked. This was also especially hard because it required multiple nodes
interacting with each other and everything needed to be synced through RPC. This created race conditions, and many many bugs :,(
2) **The Array of cards.** Because of all the different ways I could be changing a card it was super hard to account for ALL the situations. I also had to make sure that the UI was
also upadting, the array was upadting, and that the User would not be able to click until it was done. (or if they did it would use the CORRECT card). I really wish I could've been able to write it 
better but oh well.
3) **The Multiplayer** Even though I used AI to write it almost entirely it still took me like 5 hours. I was also completely knew to the whole process and didn't feel like watching a 24 hour long tutorial on how to 
set up Godot Multiplayer. Since I had NO CLUE on how to set it up I spent super long setting up the file! But i'm glad I did because if I ever make another multiplayer game I can just reuse this! 

*...and more but those are the big ones*

## CREDITS

#### *because I didn't do everything myself!*

---
1) Fonts
* Cat Font by Me (which I created first for TypeSpace)
* Handwriting Font by princess, https://www.fontspace.com/handwriting-font-f10680
2) Music
* ????

## SCREENSHOTS

#### Gameplay Screenshot:


#### Cover on Itch Screenshot:


#### Example End Screenshot:


#### Menu Screenshot:


*Made with 💖 by jyoshita!*
