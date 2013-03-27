#!/bin/bash
SRC="resume.md"
TEX="resume.tex"
OUT="resume.pdf"

check_entity() {
    if [[ $open_entity ]]; then
        unset open_entity
        echo >> $TEX
        echo "    \end{entity}" >> $TEX
    fi
}
check_position() {
    if [[ $open_position ]]; then
        unset open_position
        echo >> $TEX
        echo "        \end{position}" >> $TEX
    fi
}

cat header.tex > $TEX
sed -i s/@@moddate@@/$(date +%Y.%m.%d)/ $TEX

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
sed -i s/@@name@@/"$name"/ $TEX
sed -i s/@@email@@/"$email"/ $TEX
sed -i s/@@phone@@/"$phone"/ $TEX
sed -i s%@@website@@%"$website"% $TEX
sed -i s/@@location@@/"$location"/ $TEX

while IFS='' read line
do
    if [[ $line =~ ^##\  ]]; then
        check_position
        check_entity
        echo $line | sed -r 's/^## (.*)/\\section{\1}/g' >> $TEX
    elif [[ $line =~ ^###\  ]]; then
        check_position
        check_entity
        echo $line | grep " - " >/dev/null
        if [[ $? == 0 ]]; then
            echo $line | sed -r 's/^### (.*) - (.*)/    \\begin{entity}{\1}{\2}/' >> $TEX
        else
            echo $line | sed -r 's/^### (.*)/    \\begin{entity}{\1}{}/' >> $TEX
        fi
        open_entity=1
    elif [[ $line =~ ^####\  ]]; then
        check_position
        echo "$line" | grep - > /dev/null
        if [[ $? == 0 ]]; then
            echo $line | sed -r 's/^#### (.*) - (.*)/        \\begin{position}{\1}{\2}/' >> $TEX
        else
            echo $line | sed -r 's/^#### (.*)/        \\begin{position}{\1}{}/' >> $TEX
        fi
        open_position=1
    elif [[ $line == "" ]]; then
        echo >> $TEX
    else
        echo -n "$line" | sed 's/  $/\\par\n/' >> $TEX
    fi
    sed -i -r 's|\[(.*)\]\((.*)\)|\\href{\2}{\1}|g' $TEX
done < <(tail -n+8 $SRC)

check_position
check_entity
echo >> $TEX
echo '\\' >> $TEX
echo '\\' >> $TEX
echo "\textsl{Source:} \url{https://raw.github.com/liliff/resume/master/resume.md}" >> $TEX
echo "\end{document}" >> $TEX

sed -i -r 's/\*\*(.*)\*\*/\\textbf{\1}/g' $TEX
sed -i -r 's/\*(.*)\*/\\textsl{\1}/g' $TEX
sed -i -r 's/<http:\/\/(.*)>/\\url{\1}/g' $TEX
sed -i 's/&#42;/*/' $TEX
sed -i 's/LaTeX/\\LaTeX/' $TEX
sed -i 's/>/$>$/g' $TEX
sed -i 's/^* /-- /g' $TEX

pdflatex -interaction=nonstopmode -file-line-error -halt-on-error -shell-escape -output-directory=/tmp $TEX
mv "/tmp/${TEX%.tex}.pdf" "$OUT"
