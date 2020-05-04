//Credit to xlYoshii(GitHub: JYNxYoshii), Sniffims, Jon. Based on RE5 ASL submitted to SRC for timing implementation.
//Meant solely for IGT. 
//LiveSplit is a bit screw-y; double-check that Comparison is set to Game Time.
//Add in via Scriptable Auto Splitter in Layout settings.

state("BH6")
{
	float igt : "BH6.exe", 0x13c549c, 0x412d4;
	float slt : "BH6.exe", 0x13c549c, 0x4138C;
}

startup
{
	refreshRate = 30;
	vars.gtBuffer = 0;
}

update
{
	print("SLT: " + current.slt);
	print("IGT: " + current.igt);
}

start
{
	if (current.igt > old.igt && old.igt == 0 && current.slt > old.slt && old.slt == 0) {
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
	if (current.igt == 0 && old.igt > 0) {
		vars.gtBuffer = vars.gtBuffer + old.igt;
	}
	return TimeSpan.FromSeconds(System.Convert.ToDouble(vars.gtBuffer + current.igt));
}

reset
{
	if (current.igt < old.igt && current.igt > 0 && current.slt == 0) {
		return true;
	}
}