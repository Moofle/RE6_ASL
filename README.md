# RE6_ASL
RE6 Autosplitter for LiveSplit.

With boredom, lockdown, and nothing to do, I've finally followed through and made an autosplitter base for Resident Evil 6. If you don't know what an autosplitter is, what it does or can do, and don't run RE6, then this probably isn't for you.

Cliff notes?

<|O|> It functions, minus the automatic resets when exiting from the Chapter End screen. Automatic character/campaign selection,  mirrored IGT, automatic chapter split, and automatic resets when exiting mid-game are all implemented.

<|O|> ALWAYS set your Comparison to Game Time, or explicitly define Game Time for your Timer Component. Be sure to save your Layout.

<|X|> Because of how the game works, it retains some basic stats in memory unless updated and purges the rest on Chapter End or Main Menu. Because of this, I need a variable that checks explcitly for whether or not you're at the Main Menu to fully implement automatic resets. All contributions will be credited, either submit them to me directly or as a pull request.

<|X|> I still need help, whether just testing or delving into the memory yourself. Currently SomeMemeCrapHere#7008 if you want to use Discord.

Have fun.
--xlYoshii
