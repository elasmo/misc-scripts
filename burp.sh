#!/bin/sh
burp_jar="${HOME}/opt/BurpSuitePro/burp.jar"
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true'
java -jar -Xmx2G ${burp_jar}
