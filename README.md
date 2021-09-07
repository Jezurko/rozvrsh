# rozvrsh
Shell script to display timetable from IS created by MUNI. Use in combination with .xml timetable exported from IS (Můj rozvrh -> Možnosti zobrazení -> Formát zobrazení: Programátor -> Zobrazit). Sample file included (`muj_rozvrh.xml`).

Default path to source file is `muj_rozvrh.xml`. If you want to use your own path simply add it as an argument and `new_<script_name>` file will be generated.
Default is to display all days of the work week. If you want to hide empty days change `print_empty_days=true` to `print_empty_days=false`. Weekend days are not supported at the moment.

# Why?
I wanted a way to easily display my timetable and to be able to edit it. Since my artsy skills are poor, I had to revert to creating a script. Main advantage is that even though the `.xml` file is disgusting (looking at you variables in both Czech and English) it is quite trivial to edit and add/remove your own classes/blocks.

# Pros
* Made by me
* who doesn't like the monospace visuals of terminal?
* Add or remove classes from the timetable at your wish - simply edit the `.xml` file!

# Cons
* Made by me
* There are probably atleast thousand ways it can unexpectedly break
* The `.xml` file is quite ugly in my opinion but I can't do anything about it
* It is quite possible I will never ever touch it again, so it will die rotting
