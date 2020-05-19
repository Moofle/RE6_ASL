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

	byte slctdCampAsByte : "BH6.exe", 0x13c549c, 0x41290;
	byte slctdPlyr : "BH6.exe", 0x13c549c, 0x41294;
}

startup {
	refreshRate = 30;
	vars.gtBuffer = 0;
	vars.actIGT = 0;
	vars.actSLT = 0;
	vars.lastIGT = 0;
	vars.lastSLT = 0;
	vars.currntCamp = 0;
	vars.timeProxy = 0;
	vars.timeProxy2 = 0;
	vars.timeAdjProxy = 0;
	vars.campCurrntSlctd = new byte[4] {0, 1, 2, 3};

	settings.Add("infosection", true, "|---Information---|");
	settings.CurrentDefaultParent = "infosection";
	settings.Add("inf0", true, "Resident Evil 6 Autosplitter by xlYoshii");
	settings.Add("inf1", true, "Runs on IGT, chapter split to hopefully come soon, always set your timing method to Game Time.");
	settings.Add("inf2", true, "If you have issues, leave a message on the respective SR.C thread or file an issue on the Github repo @JYNxYoshii.");
	settings.Add("inf3", true, "If you would like to help, submit your changes however you want and I'll credit you.");
	settings.Add("inf4", true, "Site: https://github.com/JYNxYoshii/RE6_ASL");
}

update {
	vars.mainSrcArray = new float[4, 2] {{current.src1, current.src2}, {current.src3, current.src4}, {current.src5, current.src6}, {current.src7, current.src8}};
	vars.pastSrcArray = new float[4, 2] {{old.src1, old.src2}, {old.src3, old.src4}, {old.src5, old.src6}, {old.src7, old.src8}};

	for (int i = 0; i < 4; ++i) {
    	if (current.slctdCampAsByte == vars.campCurrntSlctd[i]) {
        	vars.currntCamp = vars.campCurrntSlctd[i];
        	print("-_-_Current Iterative: " + vars.currntCamp);
        	print("_-_-Current I.Index: " + i);
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
			&& current.slctdPlyr == 0) {
        	vars.actIGT = vars.mainSrcArray[i, 0];
        	vars.actSLT = vars.mainSrcArray[i, 1];
        	vars.lastIGT = vars.pastSrcArray[i, 0];
        	vars.lastSLT = vars.pastSrcArray[i, 1];
    	}
    	else if (vars.currntCamp == vars.campCurrntSlctd[i] 
				&& current.slctdPlyr == 1) {
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

split {
	if (vars.actIGT == 0 && 
		vars.actSLT == 0 && 
		vars.lastIGT > vars.actIGT && 
		vars.lastSLT > vars.actSLT &&
		vars.timeProxy == vars.timeProxy2) {
			return true;
	}
}

reset {
	if (vars.actIGT < vars.lastIGT && vars.actIGT > 0 && vars.lastSLT == 0) {
		return true;
	}
}