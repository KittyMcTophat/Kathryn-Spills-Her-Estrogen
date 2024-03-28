# tool so that the costume select menu tool script can access it
@tool
extends Node

var current_costume : Costume = preload("res://Characters/Kathryn/Costumes/normal kathryn.tres");

var default_costumes : Array[String] = [
	"res://Characters/Kathryn/Costumes/normal kathryn.tres",
	"res://Characters/Kathryn/Costumes/evil kathryn.tres",
	"res://Characters/Kathryn/Costumes/worker4560897.tres",
	"res://Characters/Kathryn/Costumes/eviler kathryn.tres",
	"res://Characters/Kathryn/Costumes/evilest kathryn.tres",
	"res://Characters/Kathryn/Costumes/evilester kathryn.tres",
	"res://Characters/Kathryn/Costumes/basketball.tres",
]

var custom_costumes : Array[Costume] = [];
