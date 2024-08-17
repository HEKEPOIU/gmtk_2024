extends Node2D
class_name lib
func disable(node: Node) -> void:
    node.process_mode = Node.PROCESS_MODE_DISABLED
    node.hide()