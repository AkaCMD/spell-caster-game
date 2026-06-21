[1mdiff --git a/assets/art/duck-wizard.png b/assets/art/duck-wizard.png[m
[1mdeleted file mode 100644[m
[1mindex 034e444..0000000[m
Binary files a/assets/art/duck-wizard.png and /dev/null differ
[1mdiff --git a/assets/art/duck-wizard.png.import b/assets/art/duck-wizard.png.import[m
[1mdeleted file mode 100644[m
[1mindex 2cb4b8d..0000000[m
[1m--- a/assets/art/duck-wizard.png.import[m
[1m+++ /dev/null[m
[36m@@ -1,40 +0,0 @@[m
[31m-[remap][m
[31m-[m
[31m-importer="texture"[m
[31m-type="CompressedTexture2D"[m
[31m-uid="uid://xhi473g77vhv"[m
[31m-path="res://.godot/imported/duck-wizard.png-68eca6998706bbf076b6669a9d3362d8.ctex"[m
[31m-metadata={[m
[31m-"vram_texture": false[m
[31m-}[m
[31m-[m
[31m-[deps][m
[31m-[m
[31m-source_file="res://assets/art/duck-wizard.png"[m
[31m-dest_files=["res://.godot/imported/duck-wizard.png-68eca6998706bbf076b6669a9d3362d8.ctex"][m
[31m-[m
[31m-[params][m
[31m-[m
[31m-compress/mode=0[m
[31m-compress/high_quality=false[m
[31m-compress/lossy_quality=0.7[m
[31m-compress/uastc_level=0[m
[31m-compress/rdo_quality_loss=0.0[m
[31m-compress/hdr_compression=1[m
[31m-compress/normal_map=0[m
[31m-compress/channel_pack=0[m
[31m-mipmaps/generate=false[m
[31m-mipmaps/limit=-1[m
[31m-roughness/mode=0[m
[31m-roughness/src_normal=""[m
[31m-process/channel_remap/red=0[m
[31m-process/channel_remap/green=1[m
[31m-process/channel_remap/blue=2[m
[31m-process/channel_remap/alpha=3[m
[31m-process/fix_alpha_border=true[m
[31m-process/premult_alpha=false[m
[31m-process/normal_map_invert_y=false[m
[31m-process/hdr_as_srgb=false[m
[31m-process/hdr_clamp_exposure=false[m
[31m-process/size_limit=0[m
[31m-detect_3d/compress_to=1[m
[1mdiff --git a/project.godot b/project.godot[m
[1mindex 4c0d1d2..d2ab14e 100644[m
[1m--- a/project.godot[m
[1m+++ b/project.godot[m
[36m@@ -10,7 +10,7 @@[m [mconfig_version=5[m
 [m
 [application][m
 [m
[31m-config/name="My Godot Template"[m
[32m+[m[32mconfig/name="Duck Wizard"[m
 run/main_scene="uid://ddr07twh7m3bm"[m
 config/features=PackedStringArray("4.7", "Forward Plus")[m
 config/icon="res://icon.svg"[m
[1mdiff --git a/src/gameplay/player/player.tscn b/src/gameplay/player/player.tscn[m
[1mindex 6b6d917..998a748 100644[m
[1m--- a/src/gameplay/player/player.tscn[m
[1m+++ b/src/gameplay/player/player.tscn[m
[36m@@ -2,7 +2,7 @@[m
 [m
 [ext_resource type="Script" uid="uid://ctn7nc2igx1r5" path="res://src/gameplay/player/player.gd" id="1_kh5p4"][m
 [ext_resource type="PackedScene" uid="uid://dljh3txvgv315" path="res://src/gameplay/player/spell_bubble.tscn" id="2_4tdni"][m
[31m-[ext_resource type="Texture2D" uid="uid://xhi473g77vhv" path="res://assets/art/duck-wizard.png" id="2_64h4j"][m
[32m+[m[32m[ext_resource type="Texture2D" uid="uid://xhi473g77vhv" path="res://assets/art/textures/duck-wizard.png" id="2_64h4j"][m
 [ext_resource type="Script" uid="uid://1t4b1nod2u7o" path="res://src/gameplay/player/spell_range_indicator.gd" id="2_xsvso"][m
 [m
 [sub_resource type="RectangleShape2D" id="RectangleShape2D_f0nsw"][m
[36m@@ -12,8 +12,6 @@[m [msize = Vector2(36, 28)[m
 script = ExtResource("1_kh5p4")[m
 walk_squash_speed = 8.0[m
 walk_squash_amount = 0.05[m
[31m-spell_effect_radius = 160.0[m
[31m-show_spell_range_indicator = true[m
 [m
 [node name="SpellRangeIndicator" type="Node2D" parent="." unique_id=1419738225][m
 unique_name_in_owner = true[m
[36m@@ -22,8 +20,8 @@[m [mscript = ExtResource("2_xsvso")[m
 [m
 [node name="Sprite2D" type="Sprite2D" parent="." unique_id=1015948085][m
 unique_name_in_owner = true[m
[31m-texture_filter = 1[m
 z_index = 11[m
[32m+[m[32mtexture_filter = 1[m
 scale = Vector2(1.2, 1.2)[m
 texture = ExtResource("2_64h4j")[m
 [m
[1mdiff --git a/src/levels/test_level.tscn b/src/levels/test_level.tscn[m
[1mindex d623d75..6cf6c99 100644[m
[1m--- a/src/levels/test_level.tscn[m
[1m+++ b/src/levels/test_level.tscn[m
[36m@@ -1,9 +1,10 @@[m
[31m-[gd_scene load_steps=5 format=3 uid="uid://bvdioybxni18t"]