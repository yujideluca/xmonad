
vol=`amixer get Master | grep '%' | head -n 1 | cut -d '[' -f 2 | cut -d '%' -f 1`
mut=`amixer get Master | grep '%' | grep -oE '[^ ]+$' | grep -m 1 off`
unmut=`amixer get Master | grep '%' | grep -oE '[^ ]+$' | grep -m 1 on`
off="[off]"
on="[on]"
if [[ -z "$mut" ]];
then
    echo "Vol:"${vol}
fi
if [[ -n "$mut" ]];
then
    echo "Vol:"${vol}"[Muted]"
fi
