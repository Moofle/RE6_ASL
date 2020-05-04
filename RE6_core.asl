//Credit to xlYoshii(GitHub: JYNxYoshii), Sniffims, Jon. Based on RE5 ASL submitted to SRC for timing.
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
	/*If IGT and SLT start from 0 and uptick, start the clock and init variable.*/
	if (current.igt > old.igt && old.igt == 0 && current.slt > old.slt && old.slt == 0) {
		vars.gtBuffer = 0;
		return true;
	}
}


isLoading
{
	/*Used primarily for testing, went for direct IGT after discrepancies were noticed.*/
	/*if (current.igt > old.igt && current.slt == 0) {
		return true;
	}
	
	else if (current.igt == 0 && current.slt == 0) {
		return true;
	}
	
	else if (current.igt == old.igt) {
		return true;
	}
	
	if (current.igt > old.igt && current.slt == 0 || current.igt == 0 && current.slt == 0) {
		return true;
	}*/
	return true;
}

gameTime
{
	/*Shamelessly pulled from the RE5 ASL on SRC. Unsure about the necessity
	of the first statement, but it seems to work fine.*/
	if (current.igt == 0 && old.igt > 0) {
		vars.gtBuffer = vars.gtBuffer + old.igt;
	}
	return TimeSpan.FromSeconds(System.Convert.ToDouble(vars.gtBuffer + current.igt));
}

reset
{
	/*What we have as IGT behaves a bit weirdly. On return to menu, it switches
	to some random value before zeroing out when you select a campaign. So,
	if the IGT drops to a low value and is greater than zero, AND the SLT is 0, then reset
	since you're in the main menu.*/
	if (current.igt < old.igt && current.igt > 0 && current.slt == 0) {
		return true;
	}
}