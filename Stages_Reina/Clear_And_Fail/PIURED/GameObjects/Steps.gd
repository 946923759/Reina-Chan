class_name Steps

## @brief The different ways of displaying the BPM. */
enum DisplayBPM {
	DISPLAY_BPM_ACTUAL, #/**< Display the song's actual BPM. */
	DISPLAY_BPM_SPECIFIED, #/**< Display a specified value or values. */
	DISPLAY_BPM_RANDOM, #/**< Display a random selection of BPMs. */
	NUM_DisplayBPM,
	DisplayBPM_Invalid
};
static func DisplayBPMToString(displayBPM:int)->String:
	match displayBPM:
		DisplayBPM.DISPLAY_BPM_ACTUAL:
			return "Actual"
		DisplayBPM.DISPLAY_BPM_SPECIFIED:
			return "Specified"
		DisplayBPM.DISPLAY_BPM_RANDOM:
			return "Random"
	return "INVALID!!"

#// Player number stuff
enum Difficulty {
	Difficulty_Beginner,
	Difficulty_Easy,
	Difficulty_Medium,
	Difficulty_Hard,
	Difficulty_Challenge,
	Difficulty_Edit,
	NUM_Difficulty,
	Difficulty_Invalid
};
static func DifficultyToString(difficulty:int)->String:
	match difficulty:
		Difficulty.Difficulty_Beginner:
			return "Beginner"
		Difficulty.Difficulty_Easy:
			return 'Easy'
		Difficulty.Difficulty_Medium:
			return "Medium"
		Difficulty.Difficulty_Hard:
			return "Hard"
		Difficulty.Difficulty_Challenge:
			return "Challenge"
		Difficulty.Difficulty_Edit:
			return "EDIT" #All caps because SM said so
	return "INVALID!!"

# @brief The name of the file where these steps are stored. */
var m_sFilename:String;
# @brief true if these Steps were loaded from or saved to disk. */
var m_bSavedToDisk:bool;
# @brief allows the steps to specify their own music file. */
var m_MusicFile:String;
# @brief What profile was used? This is ProfileSlot_Invalid if not from a profile. */
#ProfileSlot			m_LoadedFromProfile;

#/* These values are pulled from the autogen source first, if there is one. */
# @brief The hash of the steps. This is used only for Edit Steps. */
#mutable unsigned		m_iHash;
# @brief The name of the edit, or some other useful description.
# This used to also contain the step author's name. */
var m_sDescription:String;
# @brief The style of the chart. (e.g. "Pad", "Keyboard")
# In PIU simulators this is usually used to designate styles separate from
# StepsType, e.g. Single Performance charts are identical to Single in everything
# but name
var m_sChartStyle:String;
# @brief The difficulty that these steps are assigned to. */
var m_Difficulty:int;
# @brief The numeric difficulty of the Steps, ranging from MIN_METER to MAX_METER. */
var m_iMeter:int;
# @brief The radar values used for each player. */
#RadarValues			m_CachedRadarValues[NUM_PLAYERS];
#bool                m_bAreCachedRadarValuesJustLoaded;
# @brief The name of the person who created the Steps. */
var m_sCredit:String;
# @brief The name of the chart. */
var chartName:String;
# @brief How is the BPM displayed for this chart? */
var displayBPMType:int;
# @brief What is the minimum specified BPM? */
var specifiedBPMMin:float;
#/**
# * @brief What is the maximum specified BPM?
# * If this is a range, then min should not be equal to max. */
var specifiedBPMMax:float;



func toDictionary()->Dictionary:
	return {}


#/**
# * @file
# * @author Chris Danford, Glenn Maynard (c) 2001-2004
# * @section LICENSE
# * All rights reserved.
# * 
# * Permission is hereby granted, free of charge, to any person obtaining a
# * copy of this software and associated documentation files (the
# * "Software"), to deal in the Software without restriction, including
# * without limitation the rights to use, copy, modify, merge, publish,
# * distribute, and/or sell copies of the Software, and to permit persons to
# * whom the Software is furnished to do so, provided that the above
# * copyright notice(s) and this permission notice appear in all copies of
# * the Software and that both the above copyright notice(s) and this
# * permission notice appear in supporting documentation.
# * 
# * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF
# * THIRD PARTY RIGHTS. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR HOLDERS
# * INCLUDED IN THIS NOTICE BE LIABLE FOR ANY CLAIM, OR ANY SPECIAL INDIRECT
# * OR CONSEQUENTIAL DAMAGES, OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
# * OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# * PERFORMANCE OF THIS SOFTWARE.
# */
