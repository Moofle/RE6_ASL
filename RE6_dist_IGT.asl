//Credit to xlYoshii(GitHub: JYNxYoshii), Sniffims, Jon.
//Meant solely for IGT. 
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
}

startup
{
	refreshRate = 30;
	vars.gtBuffer = 0;
	vars.aIGT = 0;
	vars.aSLT = 0;
	vars.lIGT = 0;
	vars.lSLT = 0;
	
	settings.Add("leon", true, "Playing as Leon");
	settings.Add("helena", false, "Playing as Helanal");
	settings.Add("chris", false, "Playing as Chris");
	settings.Add("piers", false, "Playing as Piers");
	settings.Add("jake", false, "Playing as Jake");
	settings.Add("sherry", false, "Playing as Sherry");
	settings.Add("ada", false, "Playing as Ada");
	settings.Add("agent", false, "Playing as Agent");
}

update
{
	if (settings["leon"]) {
		vars.aIGT = current.src1;
		vars.aSLT = current.src2;
		vars.lIGT = old.src1;
		vars.lSLT = old.src2;
	}
	else if (settings["helena"]) {
		vars.aIGT = current.src2;
		vars.aSLT = current.src1;
		vars.lIGT = old.src2;
		vars.lSLT = old.src1;
	}
	else if (settings["chris"]) {
		vars.aIGT = current.src3;
		vars.aSLT = current.src4;
		vars.lIGT = old.src3;
		vars.lSLT = old.src4;
	}
	else if (settings["piers"]) {
		vars.aIGT = current.src4;
		vars.aSLT = current.src3;
		vars.lIGT = old.src4;
		vars.lSLT = old.src3;
	}
	else if (settings["jake"]) {
		vars.aIGT = current.src5;
		vars.aSLT = current.src6;
		vars.lIGT = old.src5;
		vars.lSLT = old.src6;
	}
	else if (settings["sherry"]) {
		vars.aIGT = current.src6;
		vars.aSLT = current.src5;
		vars.lIGT = old.src6;
		vars.lSLT = old.src5;
	}
	else if (settings["ada"]) {
		vars.aIGT = current.src7;
		vars.aSLT = current.src8;
		vars.lIGT = old.src7;
		vars.lSLT = old.src8;
	}
	else if (settings["agent"]) {
		vars.aIGT = current.src8;
		vars.aSLT = current.src7;
		vars.lIGT = old.src8;
		vars.lSLT = old.src7;
	}
}

start
{
	if (vars.aIGT > vars.lIGT && vars.lIGT == 0 && vars.aSLT > vars.lSLT && vars.lSLT == 0) {
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
	if (vars.aIGT == 0 && vars.lIGT > 0) {
		vars.gtBuffer = vars.gtBuffer + vars.lIGT;
	}
	
	return TimeSpan.FromSeconds(System.Convert.ToDouble(vars.gtBuffer + vars.aIGT));
}

reset
{
	if (vars.aIGT < vars.lIGT && vars.aIGT > 0 && vars.lSLT == 0) {
		return true;
	}
}