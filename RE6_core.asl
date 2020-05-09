//Credit to xlYoshii(GitHub: JYNxYoshii), Sniffims, Jon.
//LiveSplit is a bit screw-y; double-check that Comparison is set to Game Time.
//Add in via Scriptable Auto Splitter in Layout settings.
//Note to self: having virtualization enabled in your motherboard firmware DOES alter values and operation. HUGE FUCKING PROBLEM!


state("BH6")
{
	/*
	How timing works in this game: an 8-value array stores timing variables.
	One position in the array changes to represent what I've designated as the Segment Load Time (resets for map or state loads, mainly).
	This is dependent on which campaign and player you play as.
	The rest of the array catalogs the true IGT, but the SLT is the check for numerous functions currently.
	Because of this, I have little choice but to either put in a derivative function (which I don't really know how and I hate the C family),
	or to set it as an option in the SAS (Scriptable Auto Splitter) menu in LiveSplit.
	Tedious, I know, but either I'll work something out later or someone will come along with a fix.
	*/

	/*
	Map for values:
	Helena - SRC1 SLT
	Leon - SRC2 SLT
	Piers - SRC3 SLT
	Chris - SRC4 SLT
	Sherry - SRC5 SLT
	Jake - SRC6 SLT
	Agent - SRC7 SLT
	Ada - SRC8 SLT
	*/
	
	float src1 : "BH6.exe", 0x13c549c, 0x412d4;
	float src2 : "BH6.exe", 0x13c549c, 0x4138C;
	
	float src3 : "BH6.exe", 0x13c549c, 0x41444;
	float src4 : "BH6.exe", 0x13c549c, 0x414fc;
	
	float src5 : "BH6.exe", 0x13c549c, 0x415b4;
	float src6 : "BH6.exe", 0x13c549c, 0x4166c;
	
	float src7 : "BH6.exe", 0x13c549c, 0x41724;
	float src8 : "BH6.exe", 0x13c549c, 0x417dc;

	/*
	Found something that almost acts like a header section, right above the timing section. This variable changes to one of four things,
	depending on which campaign is selected (in order of appearance, from Leon to Ada):
	L, V, M, j
	Once either a campaign is selected or you return to the main menu, it returns this:
	f
	I would hazard a guess that it's meant to represent something like 'fixed', or maybe just an empty selection variable. Either way, this could potentially be isolated and
	used for automatic character selection or main menu confirmation. Because it's in the same block as the rest, there's no immediate need to scrounge about for the pointer,
	since it turns into literal elementary math to find it.
	...
	This is actually kind of fun, in a way.
	*/
	string1 campSlctFlg : "BH6.exe", 0x13c549c, 0x412a4;

	/*
	Astounding.
	So, you know how I found that flag? If you watch the memory all around that area, you'll see it alter and return booleans as bytes! After looking around, this is effectively
	the selection header! Campaign selection menu, which character you select, whether it has a campaign in memory; all of that and more are handled by a returned combination of
	bytes to dictate the current state. I'll be doing more testing, but this could allow for a much more advanced selection routine, and possibly the end of manual selection.
	Again, because it's all in the same block, simple math is all it took to find the pointer.
	*/
	byte campActv : "BH6.exe", 0x13c549c, 0x412a0;
	byte charSlctd : "BH6.exe", 0x13c549c, 0x4128c;
	byte campSlctn : "BH6.exe", 0x13c549c, 0x41298;
	byte memPlyrSlctd : "BH6.exe", 0x13c549c, 0x41388;
	byte slctdPlyr1 : "BH6.exe", 0x13c549c, 0x412d0;
	byte slctdPlyr2 : "BH6.exe", 0x13c549c, 0x41294;
}

startup
{
	refreshRate = 30;
	vars.gtBuffer = 0;
	vars.actIGT = 0;
	vars.actSLT = 0;
	vars.lastIGT = 0;
	vars.lastSLT = 0;
	vars.campSlctChar = "";
	vars.campFlgArray = new {};
	vars.mainSrcArray = new {};
	vars.currentIndex = 1;
	/*
	settings.Add("leon", true, "Playing as Leon");
	settings.Add("helena", false, "Playing as Helanal");
	settings.Add("chris", false, "Playing as Chris");
	settings.Add("piers", false, "Playing as Piers");
	settings.Add("jake", false, "Playing as Jake");
	settings.Add("sherry", false, "Playing as Sherry");
	settings.Add("ada", false, "Playing as Ada");
	settings.Add("agent", false, "Playing as Agent");
	*/
}

update
{
	print("Src-1: " + current.src1);
	print("Src--2: " + current.src2);
	print("Src---3: " + current.src3);
	print("Src----4: " + current.src4);
	print("Src-----5: " + current.src5);
	print("Src------6: " + current.src6);
	print("Src-------7: " + current.src7);
	print("Src--------8: " + current.src8);
	print("------------------------------");
	print("campSlctFlg: " + current.campSlctFlg);
	print("campSlctChar: " + vars.campSlctChar);
	print("------------------------------");
	print("---actIGT: " + vars.actIGT);
	print("--actSLT: " + vars.actSLT);
	print("---lastIGT: " + vars.lastIGT);
	print("--lastSLT: " + vars.lastSLT);
	print("------------------------------");

	vars.campFlgArray = new string[4] {"L", "V", "M", "j"};
	vars.mainSrcArray = new float[4, 2] {{current.src1, current.src2}, {current.src3, current.src4}, {current.src5, current.src6}, {current.src7, current.src8}};
	vars.pastSrcArray = new float[4, 2] {{old.src1, old.src2}, {old.src3, old.src4}, {old.src5, old.src6}, {old.src7, old.src8}};


/*
I decided to give it a go and condense everything into a loop/array combo.
The first if statement defines the constant campaign flag and works just fine.
The following two if statements appear to function for designating the timing pairs from
the pre-conceived array above, but the problem is that I need to take the current
campaign flag and somehow pull it as an integer to plug into the multi-dimensional array.
Meaning, it re-checks for a match from the constant flag variable against the flag array,
then returns the respective position or index of that matched item as a number.

I cannot think of how to get it working.
*/
	foreach (string i in vars.campFlgArray)
	{
		if (current.campSlctFlg == i) {
			vars.campSlctChar = i;
			vars.currentIndex = i.Length;
			print("-_-_Current Iterative: " + i);
		}

		if (vars.campSlctChar == i && current.slctdPlyr1 == 1) {
			vars.actIGT = vars.mainSrcArray[vars.currentIndex, 1];
			vars.actSLT = vars.mainSrcArray[vars.numIndex, 2];
			vars.lastIGT = vars.pastSrcArray[vars.numIndex, 1];
			vars.lastSLT = vars.pastSrcArray[vars.numIndex, 2];
		}

		else if (vars.campSlctChar == i && current.slctdPlyr2 == 1) {
			vars.actIGT = vars.mainSrcArray[vars.numIndex, 2];
			vars.actSLT = vars.mainSrcArray[vars.numIndex, 1];
			vars.lastIGT = vars.pastSrcArray[vars.numIndex, 2];
			vars.lastSLT = vars.pastSrcArray[vars.numIndex, 1];
		}
	}
	
	/*if (current.campSlctFlg == "L") {
		vars.campSlctChar = "L";
	}
	else if (current.campSlctFlg == "V") {
		vars.campSlctChar = "V";
	}
	else if (current.campSlctFlg == "M") {
		vars.campSlctChar = "M";
	}
	else if (current.campSlctFlg == "j") {
		vars.campSlctChar = "j";
	}*/

	

	/*if (vars.campSlctChar == "L" && current.slctdPlyr1 == 1) {
		vars.actIGT = current.src1;
		vars.actSLT = current.src2;
		vars.lastIGT = old.src1;
		vars.lastSLT = old.src2;
	}
	else if (vars.campSlctChar == "L" && current.slctdPlyr2 == 1) {
		vars.actIGT = current.src2;
		vars.actSLT = current.src1;
		vars.lastIGT = old.src2;
		vars.lastSLT = old.src1;
	}
	else if (vars.campSlctChar == "V" && current.slctdPlyr1 == 1) {
		vars.actIGT = current.src3;
		vars.actSLT = current.src4;
		vars.lastIGT = old.src3;
		vars.lastSLT = old.src4;
	}
	else if (vars.campSlctChar == "V" && current.slctdPlyr2 == 1) {
		vars.actIGT = current.src4;
		vars.actSLT = current.src3;
		vars.lastIGT = old.src4;
		vars.lastSLT = old.src3;
	}
	else if (vars.campSlctChar == "M" && current.slctdPlyr1 == 1) {
		vars.actIGT = current.src5;
		vars.actSLT = current.src6;
		vars.lastIGT = old.src5;
		vars.lastSLT = old.src6;
	}
	else if (vars.campSlctChar == "M" && current.slctdPlyr2 == 1) {
		vars.actIGT = current.src6;
		vars.actSLT = current.src5;
		vars.lastIGT = old.src6;
		vars.lastSLT = old.src5;
	}
	else if (vars.campSlctChar == "j" && current.slctdPlyr1 == 1) {
		vars.actIGT = current.src7;
		vars.actSLT = current.src8;
		vars.lastIGT = old.src7;
		vars.lastSLT = old.src8;
	}
	else if (vars.campSlctChar == "j" && current.slctdPlyr2 == 1) {
		vars.actIGT = current.src8;
		vars.actSLT = current.src7;
		vars.lastIGT = old.src8;
		vars.lastSLT = old.src7;
	}*/

	/*if (settings["leon"]) {
		vars.actIGT = current.src1;
		vars.actSLT = current.src2;
		vars.lastIGT = old.src1;
		vars.lastSLT = old.src2;
	}
	else if (settings["helena"]) {
		vars.actIGT = current.src2;
		vars.actSLT = current.src1;
		vars.lastIGT = old.src2;
		vars.lastSLT = old.src1;
	}
	else if (settings["chris"]) {
		vars.actIGT = current.src3;
		vars.actSLT = current.src4;
		vars.lastIGT = old.src3;
		vars.lastSLT = old.src4;
	}
	else if (settings["piers"]) {
		vars.actIGT = current.src4;
		vars.actSLT = current.src3;
		vars.lastIGT = old.src4;
		vars.lastSLT = old.src3;
	}
	else if (settings["jake"]) {
		vars.actIGT = current.src5;
		vars.actSLT = current.src6;
		vars.lastIGT = old.src5;
		vars.lastSLT = old.src6;
	}
	else if (settings["sherry"]) {
		vars.actIGT = current.src6;
		vars.actSLT = current.src5;
		vars.lastIGT = old.src6;
		vars.lastSLT = old.src5;
	}
	else if (settings["ada"]) {
		vars.actIGT = current.src7;
		vars.actSLT = current.src8;
		vars.lastIGT = old.src7;
		vars.lastSLT = old.src8;
	}
	else if (settings["agent"]) {
		vars.actIGT = current.src8;
		vars.actSLT = current.src7;
		vars.lastIGT = old.src8;
		vars.lastSLT = old.src7;
	}*/
}

start
{
	/*If src1 and src2 start from 0 and uptick, start the clock and init variable.*/
	/*V1 METHOD-----
	if (current.actIGT > old.actIGT && old.actIGT == 0 && current.actSLT > old.actSLT && old.actSLT == 0) {
		vars.gtBuffer = 0;
		return true;
	}*/
	
	if (vars.actIGT > vars.lastIGT && vars.lastIGT == 0 && vars.actSLT > vars.lastSLT && vars.lastSLT == 0) {
		vars.gtBuffer = 0;
		return true;
	}
}


isLoading
{
	/*Used primarily for testing, went for direct src1 after discrepancies were noticed.*/
	/*if (current.actIGT > old.actIGT && current.actSLT == 0) {
		return true;
	}
	
	else if (current.actIGT == 0 && current.actSLT == 0) {
		return true;
	}
	
	else if (current.actIGT == old.actIGT) {
		return true;
	}
	
	if (current.actIGT > old.actIGT && current.actSLT == 0 || current.actIGT == 0 && current.actSLT == 0) {
		return true;
	}*/
	
	return true;
}

gameTime
{
	/*Shamelessly pulled from the RE5 ASL on SRC. Unsure about the necessity
	of the first statement, but it seems to work fine.*/
	/*V1 METHOD-----
	if (current.actIGT == 0 && old.actIGT > 0) {
		vars.gtBuffer = vars.gtBuffer + old.actIGT;
	}
	return TimeSpan.FromSeconds(System.Convert.ToDouble(vars.gtBuffer + current.actIGT));*/
	
	if (vars.actIGT == 0 && vars.lastIGT > 0) {
		vars.gtBuffer = vars.gtBuffer + vars.lastIGT;
	}
	
	return TimeSpan.FromSeconds(System.Convert.ToDouble(vars.gtBuffer + vars.actIGT));
}

reset
{
	/*What we have as src1 behaves a bit weirdly. On return to menu, it switches
	to some random value before zeroing out when you select a campaign. So,
	if the actIGT drops to a low value and is greater than zero, AND the actSLT is 0, then reset
	since you're in the main menu.*/
	/*V1 METHOD-----
	if (current.actIGT < old.actIGT && current.actIGT > 0 && current.actSLT == 0) {
		return true;
	}*/
	
	if (vars.actIGT < vars.lastIGT && vars.actIGT > 0 && vars.lastSLT == 0) {
		return true;
	}
}