# tool so that it is accessible in the editor
@tool
extends Node

var level_names : Dictionary = {
	"res://Levels/test_scene.tscn" : "-1. Testing Level",
	"res://Levels/level_0.tscn" : "0. Welcome to Space!",
	"res://Levels/level_1.tscn" : "1. Fun with Gravity Beams",
	"res://Levels/level_2.tscn" : "2. Angy Planet",
	"res://Levels/level_3.tscn" : "3. Yes, this is technically a level",
};

var levels : Array[String] = [
	"res://Levels/test_scene.tscn",
	"res://Levels/level_0.tscn",
	"res://Levels/level_1.tscn",
	"res://Levels/level_2.tscn",
	"res://Levels/level_3.tscn",
];
