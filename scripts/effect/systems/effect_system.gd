class_name EffectSystem
extends System


static func apply(comp: EffectComponent, node: Node, from: Variant, to: Variant) -> void:
	for e in comp.effects:
		e.apply_effect(node, from, to)
