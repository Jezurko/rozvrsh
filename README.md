# rozvrsh
Shell script to display timetable from IS created by MUNI. Use in combination with .xml timetable exported from IS (Můj rozvrh -> Možnosti zobrazení -> Formát zobrazení: Programátor -> Zobrazit). Sample file included (`muj_rozvrh.xml`).

# Basics
Default path to source file is `/path/to/script/muj_rozvrh.xml`. If you want to use your own path simply add it as an argument and `new_<script_name>` file will be generated.<br />
Default is to display all days of the work week. If you want to hide empty days change `print_empty_days=true` to `print_empty_days=false`. Weekend days are not supported at the moment.

# Adding new day/class
You can place a new day anywhere inside the file - as long as it is not interfering with any existing lines. Day codes are `Po Út St Čt Pá`.
* Minimal empty day:
```xml
<den id="Út" rows="1">
<radek num="1">

    <break diff="12"/>
    <break diff="12"/>
    <break diff="12"/>
    <break diff="12"/>
    <break diff="12"/>
    <break diff="12"/>
    <break diff="12"/>
    <break diff="12"/>
    <break diff="12"/>
    <break diff="12"/>
</radek>
</den>
```
Note that number of breaks depends on your timetable (refer to `<hodiny>` tag at the beginning of your .xml)
* Minimal class definition
```xml
    <slot diff="12"/><mistnosti><mistnost><mistnostozn>R00MC0DE</mistnostozn>
    </mistnost></mistnosti><kod>IA999</kod><nazev>Subject name</nazev>
```
You have to put inside the `diff="NN"` length of the class in `hours * 12`. Only whole hours are supported - it will be rounded down if it is not divisible by 12. It is necessary to keep the position of newlines in this. At what time the class/break is is determined from the position inside the `<den>` tag.

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
