#!/bin/bash
rdiscount resume.md > resume-working.html
sed '/%%content%%/r resume-working.html' resume-template.html |
  sed '/%%content%%/d' |
  htmldoc --webpage --format pdf14 --headfootsize 6.0 --header . --footer . --pagelayout single - > resume.pdf
rm resume-working.html
