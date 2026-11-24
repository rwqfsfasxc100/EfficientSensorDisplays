# This translation file is generated automatically
# Do not modify anything directly, as this will cause the file to break for translators
# Please use Translation Tracker to modify these yourself, and contact the mod author to implement them
# https://github.com/rwqfsfasxc100/TranslationTracker/releases/latest

const TRANSLATIONS = {
	"master_locale": "en",
	"en": {
		"FASTSENSORS_CONFIG_SECT_GENERAL": {
			"string": "General",
			"version_hash": 1354717699
		},
		"FASTSENSORS_NAME": {
			"string": "Efficient Sensor Displays",
			"version_hash": 2680414709
		},
		"FASTSENSORS_BRIEF": {
			"string": "Multithreads sensors to reduce the game's CPU strain",
			"version_hash": 1507216625
		},
		"FASTSENSORS_CONFIG_TICK_RATE": {
			"string": "Sensor tick rate (hz)",
			"version_hash": 1895391657
		},
		"FASTSENSORS_CONFIG_TICK_RATE_DESC": {
			"string": "The frequency at which sensors will be sent an update packet.\n\nThis is measured as [code]1[/code] / [code]n[/code]",
			"version_hash": 1998835144
		},
		"FASTSENSORS_CONFIG_PACKET_CT": {
			"string": "Packet count",
			"version_hash": 3593071686
		},
		"FASTSENSORS_CONFIG_PACKET_CT_DESC": {
			"string": "How much to split the sensor updates by, with one packet being processed per sensor tick. The higher this value, the longer it takes for sensors to update with the same tick rate.",
			"version_hash": 2734287260
		},
		"FASTSENSORS_CONFIG_NO_NULL_VALUES": {
			"string": "Only update valid sensor outputs",
			"version_hash": 933174840
		},
		"FASTSENSORS_CONFIG_NO_NULL_VALUES_DESC": {
			"string": "Prevents sensors from updating if their value would be invalid",
			"version_hash": 2838817658
		}
	}
}