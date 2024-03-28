# tool so that it is accessible in the editor
@tool
extends Node

var level_names : Dictionary = {
	"res://Levels/test_scene.tscn" : "-1. Testing Level",
	"res://Levels/level_0.tscn" : "0. Welcome to Space!",
};

var levels : Array[String] = [
	"res://Levels/test_scene.tscn",
	"res://Levels/level_0.tscn",
];
