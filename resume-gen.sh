#!/bin/bash
rdiscount resume.md > resume-working.html
sed '/%%content%%/r resume-working.html' resume-template.html |
  sed '/%%content%%/d' |
  ./wkhtmltopdf-amd64 -B 0 -L 25mm -R 10mm -T 10mm --encoding UTF-8 - resume.pdf
rm resume-working.html
