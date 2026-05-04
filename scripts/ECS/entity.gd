class_name Entity
extends RefCounted
## entites are the base of the ECS system. by themselves, they don't have much,
## however their data and behavior is stored in components

var uid: int
var deleted: bool = false
