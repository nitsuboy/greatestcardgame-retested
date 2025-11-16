class_name EffectSystem
extends System


static func apply(comp: EffectComponent, node: Node, from: Variant, to: Variant) -> void:
	for e in comp.effects:
		e.apply_effect(node, from, to)


static func unapply(comp: EffectComponent, node: Node):
	for e in comp.effects:
		e.unapply_effect(node)
