.$GLOBALAUTOSTART &
xsettingsd &
nitrogen --restore &
compton & # transparency support
lxpanel &

syndaemon -i 2.0 -t -K -R -d

#clock &
#konsole -e sudo nethogs &
#konsole -e htop
#konsole --profile bmon &
#/home/maldus/bin/background &
tilda &
#konsole --profile Background &

conky -c /home/maldus/.config/conky/conkyrc &
nm-applet &
(cd /home/maldus/Projects/japanese/ && .env/bin/python japanese.py) &
ibus-daemon &
dunst -conf /home/maldus/.config/dunst/dunstrc &
(cd /home/maldus/bin && wallpaper -o wallpaper.png && nitrogen --restore) &
(cd /home/maldus/Projects/clippy-desktop && nw clippy-desktop) &
systemctl --user start wallpaper.timer
#docker &
#netwmpager &
#(sleep 3 && pypanel) &
