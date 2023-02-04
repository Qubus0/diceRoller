extends PanelContainer

class_name DieTypeStatistic


var die_type_data: DieTypeData
var side_grid_label := preload('res://Interface/SideStatisticLabel.tscn')

var boxed_style: bool


onready var side_grid: GridContainer = $VBox/Sides/Grid


func _ready() -> void:
	$VBox/Genral/Grid/FoldMargin/FoldContainer/FoldButton.pressed = $VBox/Sides.visible
	$VBox/Genral/Grid/TypeContainer/TypeIcon.hint_tooltip += ' (%s)' % die_type_data.type
	if boxed_style:
		add_stylebox_override("panel", null)
	update_labels()
	set_icon()
	SettingsData.listen(self, "update_labels")


func update_labels(_setting: String = "") -> void:
	$VBox/Genral/Grid/Margin/Total.text = '%s x' % die_type_data.get_total()
	$VBox/Genral/Grid/Margin2/Sum.text = '%s' % die_type_data.get_sum()
	update_side_labels(die_type_data.side_totals)


func set_icon() -> void:
	var icon: StreamTexture = load('res://Interface/Icons/%s.png' % die_type_data.type)
	if not icon:
		push_warning('No icon texture could be found for %s' % die_type_data.type)
		return
	$VBox/Genral/Grid/TypeContainer/TypeIcon.texture = icon


func _on_FoldButton_toggled(button_pressed: bool) -> void:
	$VBox/Sides.visible = button_pressed
	update_side_labels(die_type_data.side_totals)


func update_side_labels(sides: Dictionary) -> void:
	if not $VBox/Sides.visible:
		return

	var visible_row_index := 0
	for side_key in sides:
		var count_name: String = 'Count_%s' % side_key
		var type_name: String= 'Type_%s' % side_key
		var count_label: Label
		var type_label: Label

		var total: int = die_type_data.side_totals[side_key].size()
		var show_unrolled: bool = SettingsData.get_setting("show_unrolled", false)

		if not side_grid.has_node(count_name) and not side_grid.has_node(type_name):
			count_label = side_grid_label.instance()
			count_label.name = count_name
			count_label.size_flags_horizontal = Label.SIZE_EXPAND_FILL
			side_grid.add_child(count_label)

			type_label = side_grid_label.instance()
			type_label.name = type_name
			side_grid.add_child(type_label)
		else:
			count_label = side_grid.get_node(count_name)
			type_label = side_grid.get_node(type_name)

		var side : String = '?' if side_key == 0 else String(side_key)
		count_label.text = '%s x' % total if total > 0 else '-'
		type_label.text = '[%s]' % side

		var plural := '' if total == 1 else 's'
		var tooltip := '%s was rolled %s time%s' % [side, total, plural]
		if total == 0:
			tooltip = '%s was not rolled' % side
		count_label.hint_tooltip = tooltip
		type_label.hint_tooltip = tooltip

		# display stuff
		if show_unrolled or total > 0:
			visible_row_index += 1
			count_label.show()
			type_label.show()
		else:
			count_label.hide()
			type_label.hide()

		count_label.get_node('Background').visible = visible_row_index % 2
		type_label.get_node('Background').visible = visible_row_index % 2


