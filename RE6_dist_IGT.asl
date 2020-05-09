//Credit to xlYoshii(GitHub: JYNxYoshii), Jon.
//Meant solely for IGT via Steam 1.06 US. 
//LiveSplit is a bit screw-y; double-check that Comparison is set to Game Time.
//Add in via Scriptable Auto Splitter in Layout settings.

state("BH6")
{
	float src1 : "BH6.exe", 0x13c549c, 0x412d4;
	float src2 : "BH6.exe", 0x13c549c, 0x4138C;
	
	float src3 : "BH6.exe", 0x13c549c, 0x41444;
	float src4 : "BH6.exe", 0x13c549c, 0x414fc;
	
	float src5 : "BH6.exe", 0x13c549c, 0x415b4;
	float src6 : "BH6.exe", 0x13c549c, 0x4166c;
	
	float src7 : "BH6.exe", 0x13c549c, 0x41724;
	float src8 : "BH6.exe", 0x13c549c, 0x417dc;

	string1 campSlctFlg : "BH6.exe", 0x13c549c, 0x412a4;

	byte slctdPlyr1 : "BH6.exe", 0x13c549c, 0x4128c;
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
	vars.campFlgArray = new string[4] {"L", "V", "M", "j"};
}

update
{
	vars.mainSrcArray = new float[4, 2] {{current.src1, current.src2}, {current.src3, current.src4}, {current.src5, current.src6}, {current.src7, current.src8}};
	vars.pastSrcArray = new float[4, 2] {{old.src1, old.src2}, {old.src3, old.src4}, {old.src5, old.src6}, {old.src7, old.src8}};

	for (int i = 0; i < 4; ++i) {
    	if (current.campSlctFlg == vars.campFlgArray[i]) {
        	vars.campSlctChar = vars.campFlgArray[i];
        	print("-_-_Current Iterative: " + vars.campSlctChar);
        	print("_-_-Current I.Index: " + i);
    	}

    	if (vars.campSlctChar == vars.campFlgArray[i] 
			&& current.slctdPlyr1 == 1) {
        	vars.actIGT = vars.mainSrcArray[i, 0];
        	vars.actSLT = vars.mainSrcArray[i, 1];
        	vars.lastIGT = vars.pastSrcArray[i, 0];
        	vars.lastSLT = vars.pastSrcArray[i, 1];
    	}

    	else if (vars.campSlctChar == vars.campFlgArray[i] 
				 && current.slctdPlyr2 == 1) {
        	vars.actIGT = vars.mainSrcArray[i, 1];
        	vars.actSLT = vars.mainSrcArray[i, 0];
        	vars.lastIGT = vars.pastSrcArray[i, 1];
        	vars.lastSLT = vars.pastSrcArray[i, 0];
    	}
	}
}

start
{
	if (vars.actIGT > vars.lastIGT && vars.lastIGT == 0 && vars.actSLT > vars.lastSLT && vars.lastSLT == 0) {
		vars.gtBuffer = 0;
		return true;
	}
}


isLoading
{
	return true;
}

gameTime
{
	if (vars.actIGT == 0 && vars.lastIGT > 0) {
		vars.gtBuffer = vars.gtBuffer + vars.lastIGT;
	}
	
	return TimeSpan.FromSeconds(System.Convert.ToDouble(vars.gtBuffer + vars.actIGT));
}

reset
{
	if (vars.actIGT < vars.lastIGT && vars.actIGT > 0 && vars.lastSLT == 0) {
		return true;
	}
}