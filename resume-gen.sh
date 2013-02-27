#!/bin/bash
SRC="resume.md"
OUT="resume.tex"

check_entity() {
    if [[ $open_entity ]]; then
        unset open_entity
        echo >> $OUT
        echo "    \end{entity}" >> $OUT
    fi
}
check_position() {
    if [[ $open_position ]]; then
        unset open_position
        echo >> $OUT
        echo "        \end{position}" >> $OUT
    fi
}

cat header.tex > $OUT
sed -i s/@@moddate@@/$(date +%Y.%m.%d)/ $OUT

name=$(sed -n '1p' $SRC)
name=${name:2}
email=$(sed -n '3p' $SRC)
email=${email:1:-3}
phone=$(sed -n '6p' $SRC)
phone=${phone:0:-2}
website=$(sed -n '4p' $SRC)
website=${website:8:-3}
location=$(sed -n '5p' $SRC)
location=${location:0:-2}
sed -i s/@@name@@/"$name"/ $OUT
sed -i s/@@email@@/"$email"/ $OUT
sed -i s/@@phone@@/"$phone"/ $OUT
sed -i s%@@website@@%"$website"% $OUT
sed -i s/@@location@@/"$location"/ $OUT

while read line
do
    if [[ $line =~ ^##\  ]]; then
        check_position
        check_entity
        echo >> $OUT
        echo $line | sed -r 's/^## (.*)/\\section{\1}/g' >> $OUT
    elif [[ $line =~ ^###\  ]]; then
        check_entity
        echo $line | grep " - " >/dev/null
        if [[ $? == 0 ]]; then
            echo $line | sed -r 's/^### (.*) - (.*)/    \\begin{entity}{\1}{\2}/' >> $OUT
        else
            echo $line | sed -r 's/^### (.*)/    \\begin{entity}{\1}{}/' >> $OUT
        fi
        open_entity=1
    elif [[ $line =~ ^####\  ]]; then
        check_position
        echo "$line" | grep - > /dev/null
        if [[ $? == 0 ]]; then
            echo $line | sed -r 's/^#### (.*) - (.*)/        \\begin{position}{\1}{\2}/' >> $OUT
        else
            echo $line | sed -r 's/^#### (.*)/        \\begin{position}{\1}{}/' >> $OUT
        fi
        echo >> $OUT
        open_position=1
    elif [[ $line == "" ]]; then
        continue
    else
        echo $line >> $OUT
    fi
done < <(tail -n+8 $SRC)

check_position
check_entity
echo >> $OUT
echo "\end{document}" >> $OUT

sed -i 's/&#42;/*/' $OUT
sed -i -r 's|\[(.*)\]\((.*)\)|\\href{\2}{\1}|g' $OUT

#!/bin/bash
#rdiscount resume.md > resume-working.html
#sed '/%%content%%/r resume-working.html' resume-template.html |
#  sed '/%%content%%/d' |
#  ./wkhtmltopdf-amd64 -B 0 -L 25mm -R 10mm -T 10mm --encoding UTF-8 - resume.pdf
#rm resume-working.html
