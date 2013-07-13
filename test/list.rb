require 'ltdtemplate'

t = LtdTemplate.new
t.parse <<'TPL'
<< @Array?=(') @Array['list]=({
$.target.join(" and ", ", ", ", ", ", and ") "\n" })
$.*('Ruby).list /* => Ruby */
$.*('Perl, 'Ruby).list /* => Perl and Ruby */
$.*('Perl, 'PHP, 'Python, 'Ruby).list .>>
TPL

print t.render
