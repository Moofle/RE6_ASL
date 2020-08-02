//Credit to xlYoshii(GitHub: JYNxYoshii), Jon.
//Meant solely for IGT via Steam 1.06 US. 
//LiveSplit is a bit screw-y; double-check that Comparison is set to Game Time.
//Add in via Scriptable Auto Splitter in Layout settings.

//=====How it works:=====
//So, this has gradually gotten more and more clustered, and after inspiration from another guy writing ASL, I'll try to explain it.
//-
//RE6 uses an 8-value array of times in order to keep track of time. One value, which I've dubbed the Segment Time (SLT), acts exactly as that: a segment timer. 
//Load periods, cutscene periods, sub-chapters, rooms. The SLT will increment and then often zero out on change to a different setting or load point. Within the array, the SLT usually
//takes the position opposite to the currently selected character, yet in the same two-time pair. So, Leon's IGT is position 1, and his SLT is position 2. Helanal's IGT is position 2
//while her SLT is position 1. This leads to the second point: the game's time operates in sequential pairs per campaign. Leon gets 1 and 2, Chris gets 3 and 4, Jake 5 and 6, Ada 7 and 8.
//The times correspond to either player in a given campaign, with player 2's slots being reversed compared to player 1.
//-
//The game's level display is universal; it displays the campaign in addition to the stage and cutscene. Because of this constantly changing variable, I decided to use a loop with two
//lists alongside some other basic checks in order to act as a crude form of pattern matching. Without this, the game would have no less than 100 splits. It will go through and check if
//the current and old level values are in the map. If it is, and the other checks pass, then it splits. There is a breakpoint map, where any level that is contained within it will use the
//chapter split method, which will pause the timer at the end of each chapter. If sub-chapter splits are not enabled, then it will always split with the chapter method.

//Theory pipeline: Loop Check => Level Map(s) => Split according to Chapter or Sub-Chapter method
//Livesplit pipeline: Update => (IfActive)isLoading, gameTime, Reset => (resetIsFalse)Split =/> (IfInactive)Start

state("BH6") {
	float src1 : "BH6.exe", 0x13c549c, 0x412d4;
	float src2 : "BH6.exe", 0x13c549c, 0x4138C;
	
	float src3 : "BH6.exe", 0x13c549c, 0x41444;
	float src4 : "BH6.exe", 0x13c549c, 0x414fc;
	
	float src5 : "BH6.exe", 0x13c549c, 0x415b4;
	float src6 : "BH6.exe", 0x13c549c, 0x4166c;
	
	float src7 : "BH6.exe", 0x13c549c, 0x41724;
	float src8 : "BH6.exe", 0x13c549c, 0x417dc;

	byte pSlctdCampAsByte : "BH6.exe", 0x13c549c, 0x41290;
	ushort pCurrntLvl : "BH6.exe", 0x13c549c, 0x412a4;
	byte pSlctdPlyr : "BH6.exe", 0x13c549c, 0x41294;
	byte pCampaignDifficulty : "BH6.exe", 0x13c549c, 0x412a0;

	byte4 pMDS : "BH6.exe", 0x14641F8, 0x382c, 0x2c, 0x4;
}

startup {
	//Halved the update rate; default is 60, will toy with this more later
	refreshRate = 60;
	
	//Game Time Placeholder, meant for additional IGT during zeroization
	vars.gtBuffer = 0;

	//Timing Placeholders
	vars.actIGT = 0;
	vars.actSLT = 0;
	vars.lastIGT = 0;
	vars.lastSLT = 0;

	//Current Campaign Placeholder and Comparison Array
	vars.currntCamp = 0;
	vars.campCurrntSlctd = new byte[4] {0, 1, 2, 3};

	//Paranoia Timing Check Placeholders
	vars.timeProxy = 0;
	vars.timeProxy2 = 0;
	vars.timeAdjProxy = 0;

	settings.Add("optionals", false, "|---Optional Features---|");
	settings.CurrentDefaultParent = "optionals";
	settings.Add("opt0", false, "Enable splitting by sub-chapters (1-1, 1-2, etc.)");
	settings.Add("opt1", false, "[ToBeImplemented]Enable splitting by sub-chapters AND cutscenes");

	settings.CurrentDefaultParent = null;
	settings.Add("infosection", true, "|---Information---|");
	settings.CurrentDefaultParent = "infosection";
	settings.Add("inf0", true, "Resident Evil 6 Autosplitter by xlYoshii");
	settings.Add("inf1", true, "Runs on IGT, chapter split is in, always set your timing method to Game Time.");
	settings.Add("inf2", true, "If you have issues, leave a message on the respective SR.C thread or file an issue on the Github repo @JYNxYoshii.");
	settings.Add("inf3", true, "If you would like to help, submit your changes however you want and I'll credit you.");
	settings.Add("inf4", true, "Site: https://github.com/JYNxYoshii/RE6_ASL");
}

update {
	//MUST be put here, in the Update state or the loop doesn't actually recognize anything from these arrays and will NOT error out. Seriously, fuck ASL/C#.
	vars.mainSrcArray = new float[4, 2] {{current.src1, current.src2}, {current.src3, current.src4}, {current.src5, current.src6}, {current.src7, current.src8}}; //Current campaign time pairings
	vars.pastSrcArray = new float[4, 2] {{old.src1, old.src2}, {old.src3, old.src4}, {old.src5, old.src6}, {old.src7, old.src8}}; //Last updated campaign time pairings

	//Core loop; processes current campaign, time pair to use, consistency check to use, then assigns correct time pair based on the player selected.
	for (int i = 0; i < 4; ++i) {
		//Campaign selection
    	if (current.pSlctdCampAsByte == vars.campCurrntSlctd[i]) {
        	vars.currntCamp = vars.campCurrntSlctd[i];
    	}

		//Consistency check based on campaign, written to accommodate the end of index (Ada's campaign). Uses the campaign before Ada if Ada's selected, otherwise goes to the next campaign.
		if (vars.currntCamp == 3) {
			vars.timeAdjProxy = vars.currntCamp - 1;
		}
		else {
			vars.timeAdjProxy = vars.currntCamp + 1;
		}

		//Consistency check assignment, for time alterations.
		vars.timeProxy = vars.mainSrcArray[vars.timeAdjProxy, 0];
		vars.timeProxy2 = vars.pastSrcArray[vars.timeAdjProxy, 0];

		//Time pair assignment. Takes campaign result, checks for current player, then assigns the correct time pair, both for current and last time value reads.
		if (vars.currntCamp == vars.campCurrntSlctd[i]) {
			if (current.pSlctdPlyr == 0) {
				vars.actIGT = vars.mainSrcArray[i, 0];
				vars.actSLT = vars.mainSrcArray[i, 1];
				vars.lastIGT = vars.pastSrcArray[i, 0];
				vars.lastSLT = vars.pastSrcArray[i, 1];
			}
			else if (current.pSlctdPlyr == 1) {
				vars.actIGT = vars.mainSrcArray[i, 1];
				vars.actSLT = vars.mainSrcArray[i, 0];
				vars.lastIGT = vars.pastSrcArray[i, 1];
				vars.lastSLT = vars.pastSrcArray[i, 0];
			}
		}
	}
}

//Running this as an IGT pull, so have this always enabled.
isLoading {
	return true;
}

//Interesting method that I like for keeping the game time. Using a time buffer, it will add the last known time to the current time value if the time resets to 0, which it does between chapters.
gameTime {
	if (vars.actIGT == 0 && vars.lastIGT > 0) {
		vars.gtBuffer = vars.gtBuffer + vars.lastIGT;
	}
	
	return TimeSpan.FromSeconds(System.Convert.ToDouble(vars.gtBuffer + vars.actIGT));
}

//If the current time is reset but contains one of the random placeholder values, but the segment loader is 0, then reset the clock. Works when exiting from mid-game, not from chapter end exit.
reset {
	return (vars.actIGT < vars.lastIGT && vars.actIGT > 0 && vars.actSLT == 0);
}

//Both split methods. If sub-chapter splits are enabled, run block one. Otherwise, run chapter split (block 2).
//Simplistic Literal format inspired by Mysterion06, since he showed me that ASL really requires that much of a writing handicap.
//Hey, it was either this way or learn the complexities of C# and Livesplit, so it should be obvious which route I preferred.
split {
	if (settings["opt0"] == true) {
		if ((current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 105 && old.pCurrntLvl == 104) || //Beginning of Leon
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 101 && old.pCurrntLvl == 105) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 102 && old.pCurrntLvl == 101) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 103 && old.pCurrntLvl == 102) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 200 && old.pCurrntLvl == 210) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 201 && old.pCurrntLvl == 200) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 202 && old.pCurrntLvl == 201) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 279 && old.pCurrntLvl == 202) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 209 && old.pCurrntLvl == 279) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 203 && old.pCurrntLvl == 209) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 204 && old.pCurrntLvl == 203) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 206 && old.pCurrntLvl == 204) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 250 && old.pCurrntLvl == 206) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 510 && old.pCurrntLvl == 552) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 511 && old.pCurrntLvl == 510) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 512 && old.pCurrntLvl == 511) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 514 && old.pCurrntLvl == 1151) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 701 && old.pCurrntLvl == 770) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 706 && old.pCurrntLvl == 701) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 702 && old.pCurrntLvl == 706) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 773 && old.pCurrntLvl == 702) || //End of Leon
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 501 && old.pCurrntLvl == 500) || //Beginning of Chris
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 502 && old.pCurrntLvl == 501) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 503 && old.pCurrntLvl == 502) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 300 && old.pCurrntLvl == 503) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 301 && old.pCurrntLvl == 300) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 302 && old.pCurrntLvl == 301) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 303 && old.pCurrntLvl == 302) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 504 && old.pCurrntLvl == 303) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 506 && old.pCurrntLvl == 504) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 507 && old.pCurrntLvl == 506) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 508 && old.pCurrntLvl == 507) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 512 && old.pCurrntLvl == 508) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 550 && old.pCurrntLvl == 512) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 800 && old.pCurrntLvl == 550) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 801 && old.pCurrntLvl == 800) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 872 && old.pCurrntLvl == 801) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 851 && old.pCurrntLvl == 872) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 901 && old.pCurrntLvl == 851) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 902 && old.pCurrntLvl == 901) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 972 && old.pCurrntLvl == 902) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 903 && old.pCurrntLvl == 972) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 304 && old.pCurrntLvl == 903) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 305 && old.pCurrntLvl == 304) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 307 && old.pCurrntLvl == 305) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 302 && old.pCurrntLvl == 307) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 306 && old.pCurrntLvl == 302) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 400 && old.pCurrntLvl == 306) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 401 && old.pCurrntLvl == 400) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 402 && old.pCurrntLvl == 401) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 600 && old.pCurrntLvl == 402) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 601 && old.pCurrntLvl == 600) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 602 && old.pCurrntLvl == 601) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 551 && old.pCurrntLvl == 602) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 506 && old.pCurrntLvl == 551) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 515 && old.pCurrntLvl == 506) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 579 && old.pCurrntLvl == 515) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 510 && old.pCurrntLvl == 579) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 578 && old.pCurrntLvl == 510) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 904 && old.pCurrntLvl == 578) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 902 && old.pCurrntLvl == 904) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 905 && old.pCurrntLvl == 902) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 950 && old.pCurrntLvl == 905) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 1000 && old.pCurrntLvl == 950) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 1001 && old.pCurrntLvl == 1000) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 1003 && old.pCurrntLvl == 1001) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 207 && old.pCurrntLvl == 1003) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 203 && old.pCurrntLvl == 207) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 272 && old.pCurrntLvl == 203) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 574 && old.pCurrntLvl == 272) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 509 && old.pCurrntLvl == 574) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 516 && old.pCurrntLvl == 509) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 578 && old.pCurrntLvl == 516) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 802 && old.pCurrntLvl == 578) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 871 && old.pCurrntLvl == 802) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 804 && old.pCurrntLvl == 871) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 751 && old.pCurrntLvl == 804) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 706 && old.pCurrntLvl == 751) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 703 && old.pCurrntLvl == 706) ||
			(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 702 && old.pCurrntLvl == 703)) {
			return true; //If the level changed and the level map contains both the current and old values, then split.
		}
		else if ((current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 103) || //Beginning of Leon
				(current.pCurrntLvl == 203 && old.pCurrntLvl == 203) ||
				(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 1152) ||
				(current.pCurrntLvl != old.pCurrntLvl && current.pCurrntLvl == 700) || 
				(current.pCurrntLvl == 1102 && old.pCurrntLvl == 1102)) {
					if (vars.actIGT == 0 && vars.actSLT == 0 && 
						vars.lastIGT > vars.actIGT && vars.lastSLT > vars.actSLT &&
						vars.timeProxy == vars.timeProxy2) {
							return true; //If the level changed and the breakpoint map contains the current level, then run the chapter split routine.
						}
					}
		else {
			return false; //Explicit declaration, for attempted consistency.
		}
	}
	else if (settings["opt0"] == false) {
	//Chapter splits. If both IGT and segment times are 0 (end of chapter zeroes out ALL values), and the last known values for segment and IGT are greater than the current values, then split if consistency check is met.
		if (vars.actIGT == 0 && vars.actSLT == 0 && 
			vars.lastIGT > vars.actIGT && 
			vars.lastSLT > vars.actSLT && 
			vars.timeProxy == vars.timeProxy2) {
				return true;
		}
		else {
			return false; //Explicit declaration, for attempted consistency.
		}
	}
}

start { //If the last values for the IGT and segment times were 0 and the current values are greater than the old values (so, they've increased), initialize the game time buffer and start.
	if (vars.actIGT > vars.lastIGT && 
		vars.lastIGT == 0 && 
		vars.actSLT > vars.lastSLT && 
		vars.lastSLT == 0) {
			vars.gtBuffer = 0;
			return true;
	}
}