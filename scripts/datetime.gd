extends RefCounted

class_name DateTime

var year: int
var month: int
var day: int
var hour: int
var minute: int
var second: int
var weekday: int
var dst: bool

static func now() -> DateTime:
	var dt = Time.get_datetime_dict_from_system()
	var instance = DateTime.new()
	instance.year    = dt.year
	instance.month   = dt.month
	instance.day     = dt.day
	instance.hour    = dt.hour
	instance.minute  = dt.minute
	instance.second  = dt.second
	instance.weekday = dt.weekday
	instance.dst     = dt.dst
	return instance

func format(fmt: String) -> String:
	var result = fmt
	result = result.replace("%Y", str(year))
	result = result.replace("%m", str(month).pad_zeros(2))
	result = result.replace("%d", str(day).pad_zeros(2))
	result = result.replace("%H", str(hour).pad_zeros(2))
	result = result.replace("%M", str(minute).pad_zeros(2))
	result = result.replace("%S", str(second).pad_zeros(2))
	return result

func toString() -> String:
	return format("%Y-%m-%d %H:%M:%S")
