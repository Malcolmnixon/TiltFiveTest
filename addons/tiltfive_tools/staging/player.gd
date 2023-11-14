class_name T5ToolsPlayer
extends T5XRRig


## Get the player viewport
func get_player_viewport() -> SubViewport:
	return self


## Get the player origin
func get_player_origin() -> T5Origin3D:
	return $Origin


## Get the player camera
func get_player_camera() -> T5Camera3D:
	return $Origin/Camera


## Get the player wand
func get_player_wand(wand_num : int) -> T5Controller3D:
	return get_node_or_null("Origin/Wand_%d" % (wand_num + 1))


## Find the T5ToolsPlayer from a child node
static func find_instance(node : Node) -> T5ToolsPlayer:
	# Walk the node tree
	while node:
		# If we have the player then return it
		if node is T5ToolsPlayer:
			return node

		# Walk up to the parent
		node = node.get_parent()

	# Not found
	return null
