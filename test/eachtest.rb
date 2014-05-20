require 'ltdtemplate'

t = LtdTemplate.new
t.parse <<'TPL'
<<a=(1,2,3..'four,4,'five,5,'six,6,7,7)
body=({ $.*($.method,_[0].type,_[0],_[1]).join(",") "\n" })
"each:\n" a.each(body)
"\neach_rnd:\n" a.each_rnd(body)
"\neach_seq:\n" a.each_seq(body)
.>>
TPL
print t.render
