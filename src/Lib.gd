extends Node2D
class_name UiHelper
static func disable(node: Node) -> void:
	node.process_mode = Node.PROCESS_MODE_DISABLED
	node.hide()
