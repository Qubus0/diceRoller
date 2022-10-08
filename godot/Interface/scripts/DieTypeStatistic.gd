extends VBoxContainer

class_name DieTypeStatistic


var die_type_data: DieTypeData
var side_grid_label := preload('res://Interface/SideStatisticLabel.tscn')


func _ready() -> void:
	$Genral/Grid/FoldMargin/FoldContainer/FoldButton.pressed = $Sides.visible
	$Genral/Grid/TypeContainer/TypeIcon.hint_tooltip += ' (%s)' % die_type_data.type
	update_labels()
	set_icon()


func update_labels() -> void:
	$Genral/Grid/Margin/Total.text = '%s x' % die_type_data.get_total()
	$Genral/Grid/Margin2/Sum.text = '%s' % die_type_data.get_sum()
	update_side_labels(die_type_data.side_totals)


func set_icon() -> void:
	var icon: StreamTexture = load('res://Interface/Icons/%s.png' % die_type_data.type)
	if not icon:
		push_warning('No icon texture could be found for %s' % die_type_data.type)
		return
	$Genral/Grid/TypeContainer/TypeIcon.texture = icon


func _on_FoldButton_toggled(button_pressed: bool) -> void:
	$Sides.visible = button_pressed
	update_side_labels(die_type_data.side_totals)


func update_side_labels(sides: Dictionary) -> void:
	if not $Sides.visible:
		return

	for side_key in sides:
		var count_name: String = 'Count_%s' % side_key
		var type_name: String= 'Type_%s' % side_key
		var count_label: Label
		var type_label: Label

		if not ($Sides/Grid.has_node(count_name) and $Sides/Grid.has_node(type_name)):
			count_label = side_grid_label.instance()
			count_label.name = count_name
			count_label.size_flags_horizontal = Label.SIZE_EXPAND_FILL
			$Sides/Grid.add_child(count_label)

			type_label = side_grid_label.instance()
			type_label.name = type_name
			$Sides/Grid.add_child(type_label)
		else:
			count_label = $Sides/Grid.get_node(count_name)
			type_label = $Sides/Grid.get_node(type_name)


		var total: int = die_type_data.side_totals[side_key].size()
		var side : String = String(side_key) if not side_key == 0 else '?'
		count_label.text = '%s x' % total if total > 0 else '-'
		type_label.text = '[%s]' % side

		var plural := '' if total == 1 else 's'
		var tooltip := '%s was rolled %s time%s' % [side, total, plural]
		if total == 0:
			tooltip = '%s was not rolled' % side
		count_label.hint_tooltip = tooltip
		type_label.hint_tooltip = tooltip

		if not side_key % 2: # uneven
			count_label.get_node('Background').visible = false
			type_label.get_node('Background').visible = false
