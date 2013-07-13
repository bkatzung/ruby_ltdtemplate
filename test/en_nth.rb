require 'ltdtemplate'

t = LtdTemplate.new
t.parse <<'TPL'
<< Number?=(') Number['en_nth]=({
$.var(.. 'n, $.target) $.var(.. 'n10, n.abs%(10), 'n100, n.abs%(100))
n $.if({ n100>=(11)&(n100<=(20)) }, 'th, { n10==(1) }, 'st,
{ n10==(2) }, 'nd, { n10==(3) }, 'rd, 'th) })

n=(-11) $.loop({ n<=(24) }, { n.en_nth n=(n+(1)) }).join(", ") >>
TPL

print t.render
