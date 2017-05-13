cd `dirname $0`
scp debroot/*.deb lakka.kapsi.fi:public_html/debs
ssh lakka.kapsi.fi bin/update_debs.sh
