include <BOSL2/std.scad>;

$fs = 0.1;

/*[Box Size]*/
// The value for how many pegboard holes wide the box should be.
Spacing_Between = 3;
// The value for deep the box should be.
Inner_Depth_Size = 50;
// The value for heigth the box should be.
Inner_Height_Size = 50;

/*[Thickness Size]*/
// The value for the thickness of the sides and front of the box.
Thickness_Sides = 2;
// The value for the thickness of the bottom of the box.
Thickness_Bottom = 2;

/*[Options]*/
// Choose whether the top surface should be flat or diagonal.
Diagonal = true;
// The height of the front when the top surface is diagonal.
Diagonal_Front_Height_Size = 20;

// Select how you'd like to divide the data
Depth_Divid_Type = "Size"; // [None, Count, Size]
//Number of divisions in the depth direction.
divisions_depth = 6; //[1:10]
// Depth division points(mm)
depthSplits = "2,5,7,12";

// Select how you'd like to divide the data
Width_Divid_Type = "Size"; // [None, Count, Size]
//Number of divisions in the width direction.
divisions_width = 3; //[1:10]
//Number of divisions in the width direction.
divisions_width_positions = 3;
// Width division points(mm)
widthSplits = "10,25,52,80";


/////////////////////////////
///// ここからはロジック /////
/////////////////////////////

front_height = Diagonal == false ? Inner_Height_Size : Diagonal_Front_Height_Size;
thickness_back = 3 * 1; // 奥行きの板の厚み(3固定)
radius = Thickness_Sides / 10; // エッジを丸めるためのRadiusを計算

// ホックサイズ
hook_width = 5 * 1; // ホックの幅
hook_height = 34 * 1; // ホックの高さ
hook_thickness = 5 * 1; // ホックの厚み(削除する部分の厚み)

// 内径寸法
inner_width = Spacing_Between * 25 + hook_width ;  // 幅内径
inner_depth = Inner_Depth_Size;   // 奥行内径
inner_height = Inner_Height_Size;  // 高さ内径

// 外径寸法を計算(丸めを考慮)
outer_width = inner_width + (Thickness_Sides * 2) - (radius * 2);
outer_depth = inner_depth + thickness_back + Thickness_Sides - (radius * 2);
outer_height = inner_height + Thickness_Bottom - (radius * 2);

// 丸めを計算に入れた厚みを計算
thick_sides_r = Thickness_Sides - (radius * 2); // 左右膨らむ
thick_bottom_r = Thickness_Bottom - (radius * 2); // 上下側膨らむ
thick_back_r = thickness_back - (radius * 2); // 奥行き側膨らむ

// ホックの位置を計算(奥行/高さは左右同じ)
hook_y = Thickness_Sides + inner_depth - 1; // 手前壁 + 奥行内径 - 切り出しマージン
hook_z = outer_height - hook_height - hook_width; // 下側の壁分オフセット + ひっかけフックの高さ - ひっかけ部分の厚み

// ひっかけ部分左側の位置を計算
hook_left_x = Thickness_Sides; // 左側の壁分オフセット

// ひっかけ部分右側の位置を計算
hook_right_x = outer_width - Thickness_Sides - hook_width; // 右側の壁分オフセット - ホックの幅

// 丸めた後の外径を計算 
outer_width_r = outer_width + (radius * 2); // 幅外径 + 丸め分
outer_depth_r = outer_depth + (radius * 2); // 奥行外径 + 丸め分
outer_height_r = outer_height + (radius * 2); // 高さ外径 + 丸め分

//Number of divisions in the depth direction.
div_d_space = inner_depth / divisions_depth;

// 指定サイズでの奥行分割点を配列に入れる
div_d_points = [for (val = str_split(depthSplits, ",")) parse_int(val)];

//Number of divisions in the width direction.
div_w_space = inner_width / divisions_width;

// 指定サイズでの幅分割点を配列に入れる
div_w_points = [for (val = str_split(widthSplits, ",")) parse_int(val)];

// 斜め削除用の箱を作成
points = [
    [outer_height_r, outer_depth_r - 5],
    [outer_height_r, 0],
    [front_height, 0],
    [front_height, 10]
];

// 箱の作成

// 全体位置を真ん中に持ってくる
translate([outer_width_r / -2, outer_depth_r / -2, 0]){
    difference() {
        minkowski() {
            // 丸みをつけるための球体
            sphere(r = radius, $fn = 32); // 半径2mmの球体で丸みを作成

            translate([radius, radius, radius])
            difference(){
                union(){
                    difference() {
                        // 外側の箱
                        cube([outer_width, outer_depth, outer_height], center = false);
                        
                        // 内側の空洞
                        translate([Thickness_Sides, Thickness_Sides, Thickness_Bottom])
                            cube([inner_width, inner_depth, inner_height+1], center = false);
                    }

                    // 仕切り作成
                    if (Depth_Divid_Type == "Count") {
                        for(i = [1 : divisions_depth - 1]) {
                            echo(i);
                            translate([0, Thickness_Sides + (div_d_space * i) - radius, 0])
                                cube([outer_width, thick_sides_r, outer_height], center = false);
                        }
                    }else if (Depth_Divid_Type == "Size") {
                        for(i = [0 : len(div_d_points) - 1]) {
                            echo(i);
                            translate([0, Thickness_Sides + (div_d_points[i] - radius), 0])
                                cube([outer_width, thick_sides_r, outer_height], center = false);
                        }
                    }

                    if (Width_Divid_Type == "Count"){
                        for(i = [1 : divisions_width - 1]) {
                            echo(i);
                            translate([Thickness_Sides + (div_w_space * i) - radius, 0, 0])
                                cube([thick_sides_r, outer_depth, outer_height], center = false);
                        }
                    }else if (Width_Divid_Type == "Size") {
                        for(i = [0 : len(div_w_points) - 1]) {
                            echo(i);
                            translate([Thickness_Sides + (div_w_points[i] - radius), 0, 0])
                                cube([thick_sides_r, outer_depth, outer_height], center = false);
                        }
                    }

                }

                // 上面の斜め削除
                if (Diagonal == true) {
                    translate([outer_width_r, 0, 0])
                        rotate([0, -90, 0])
                            linear_extrude(outer_width_r)
                                polygon(points);
                }
            }
        }

        // ひっかけ部分左側削除
        translate([hook_left_x + (radius*2), hook_y, hook_z])
            cube([hook_width, hook_thickness, hook_height], center = false);

        // ひっかけ部分右側削除
        translate([hook_right_x + (radius*2), hook_y, hook_z])
            cube([hook_width, hook_thickness, hook_height], center = false);

    }
}