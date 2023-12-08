ecrifles_Init()
{
	level.gametype = getcvar("g_gametype");

	// Map Entity Removal
	thread maps\mp\gametypes\_mapentity::Remove_Map_Entity();

}