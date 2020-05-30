//Credit to xlYoshii(GitHub: JYNxYoshii), Jon.
//Meant solely for IGT via Steam 1.06 US. 
//LiveSplit is a bit screw-y; double-check that Comparison is set to Game Time.
//Add in via Scriptable Auto Splitter in Layout settings.

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
	string1 pCSF : "BH6.exe", 0x13c549c, 0x412a4;
	ushort pCurrntLvl : "BH6.exe", 0x13c549c, 0x412a4;
	byte pSlctdPlyr : "BH6.exe", 0x13c549c, 0x41294;
	byte pCampaignDifficulty : "BH6.exe", 0x13c549c, 0x412a0;
}

init {
	current.lvl = 0;
}

startup {
	refreshRate = 30;
	
	vars.gtBuffer = 0;
	vars.actIGT = 0;
	vars.actSLT = 0;
	vars.lastIGT = 0;
	vars.lastSLT = 0;

	vars.currntCamp = 0;
	vars.campCurrntSlctd = new byte[4] {0, 1, 2, 3};

	vars.timeProxy = 0;
	vars.timeProxy2 = 0;
	vars.timeAdjProxy = 0;

//Level maps for the campaigns. Should not include cutscenes, more to test.
	vars.LvlMap = new List<int> {104, 105, 101, 102, 103, 
								210, 200, 201, 202, 279, 209, 
								203, 204, 206, 250, 
								552, 510, 511, 512, 514, 
								770, 701, 706, 702, 773, 
								500, 501, 502, 503, 
								300, 301, 302, 303, 
								504, 506, 507, 508, 512, 550, 
								800, 801, 872, 851, 
								901, 902, 972, 903, 
								304, 305, 307, 302, 306, 
								400, 401, 402, 
								600, 601, 602, 
								551, 506, 515, 579, 510, 578, 
								904, 902, 905, 950, 
								1000, 1001, 1003, 
								207, 203, 272, 
								574, 509, 516, 578, 
								802, 871, 804, 
								751, 706, 703, 702};
	vars.currntLvlCheck = false;

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
	vars.mainSrcArray = new float[4, 2] {{current.src1, current.src2}, {current.src3, current.src4}, {current.src5, current.src6}, {current.src7, current.src8}};
	vars.pastSrcArray = new float[4, 2] {{old.src1, old.src2}, {old.src3, old.src4}, {old.src5, old.src6}, {old.src7, old.src8}};

	for (int i = 0; i < 4; ++i) {
    	if (current.pSlctdCampAsByte == vars.campCurrntSlctd[i]) {
        	vars.currntCamp = vars.campCurrntSlctd[i];
    	}

		if (settings["opt0"] == true) {
			if (current.pCurrntLvl != old.pCurrntLvl && vars.LvlMap.Contains(current.pCurrntLvl)) {
				vars.currntLvlCheck = true;
			}
			else {
				vars.currntLvlCheck = false;
			}
		}

		if (vars.currntCamp == 3) {
			vars.timeAdjProxy = vars.currntCamp - 1;
		}
		else {
			vars.timeAdjProxy = vars.currntCamp + 1;
		}

		vars.timeProxy = vars.mainSrcArray[vars.timeAdjProxy, 0];
		vars.timeProxy2 = vars.pastSrcArray[vars.timeAdjProxy, 0];

    	if (vars.currntCamp == vars.campCurrntSlctd[i] 
			&& current.pSlctdPlyr == 0) {
        	vars.actIGT = vars.mainSrcArray[i, 0];
        	vars.actSLT = vars.mainSrcArray[i, 1];
        	vars.lastIGT = vars.pastSrcArray[i, 0];
        	vars.lastSLT = vars.pastSrcArray[i, 1];
    	}
    	else if (vars.currntCamp == vars.campCurrntSlctd[i] 
				&& current.pSlctdPlyr == 1) {
        	vars.actIGT = vars.mainSrcArray[i, 1];
        	vars.actSLT = vars.mainSrcArray[i, 0];
        	vars.lastIGT = vars.pastSrcArray[i, 1];
        	vars.lastSLT = vars.pastSrcArray[i, 0];
    	}
	}
}

start {
	if (vars.actIGT > vars.lastIGT && 
		vars.lastIGT == 0 && 
		vars.actSLT > vars.lastSLT && 
		vars.lastSLT == 0) {
			vars.gtBuffer = 0;
			return true;
	}
}

isLoading {
	return true;
}

gameTime {
	if (vars.actIGT == 0 && vars.lastIGT > 0) {
		vars.gtBuffer = vars.gtBuffer + vars.lastIGT;
	}
	
	return TimeSpan.FromSeconds(System.Convert.ToDouble(vars.gtBuffer + vars.actIGT));
}

reset {
	if (vars.actIGT < vars.lastIGT && vars.actIGT > 0 && vars.actSLT == 0) {
		return true;
	}
}

split {
	//Chapter Split
	if (settings["opt0"] == false &&
		vars.actIGT == 0 && 
		vars.actSLT == 0 && 
		vars.lastIGT > vars.actIGT && 
		vars.lastSLT > vars.actSLT &&
		vars.timeProxy == vars.timeProxy2) {
			return true;
	}
	else {
		return vars.currntLvlCheck;
	}
}