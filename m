From: Michael Nelson <mikenel@iapetus.com>
Date: Sat, 17 Jun 2000 03:06:44 +0000
Subject: [Linux-ia64] ia-64 backend dependency on c front end
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01BFD809.119BE148"
Message-Id: <marc-linux-ia64-105590678205160@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01BFD809.119BE148
Content-Type: text/plain;
	charset="iso-8859-1"

FYI.
 
I discovered this evening that the IA-64 backend (specifically the
def_builtin() macro) depends on builtin_function() which is located in
c-decl.c, while trying to build a IA-64 cross compiler with a custom front
end. Dumping that function into my frontend solves the problem, so no big
deal. 
 
-mike
 
 

------_=_NextPart_001_01BFD809.119BE148
Content-Type: text/html;
	charset="iso-8859-1"

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">


<META content="MSHTML 5.00.2920.0" name=GENERATOR></HEAD>
<BODY>
<DIV><FONT size=2><FONT face=Arial><SPAN 
class=250400003-17062000>FYI.</SPAN></FONT></FONT></DIV>
<DIV><FONT size=2><FONT face=Arial><SPAN 
class=250400003-17062000></SPAN></FONT></FONT>&nbsp;</DIV>
<DIV><FONT size=2><FONT face=Arial><SPAN class=250400003-17062000>I discovered 
this evening that the IA-64 backend (specifically the def_builtin() macro) 
depends on builtin_function() which is located in </SPAN></FONT></FONT><FONT 
size=2><FONT face=Arial><SPAN class=250400003-17062000>c-decl.c, while 
</SPAN></FONT></FONT><FONT size=2><FONT face=Arial><SPAN 
class=250400003-17062000>trying to build a IA-64 cross&nbsp;</SPAN><SPAN 
class=250400003-17062000></SPAN>c<SPAN class=250400003-17062000>ompiler with a 
custom front end. Dumping that function into my frontend solves the problem, so 
no big deal. </SPAN></FONT></FONT></DIV>
<DIV><FONT size=2><FONT face=Arial><SPAN 
class=250400003-17062000></SPAN></FONT></FONT>&nbsp;</DIV>
<DIV><FONT size=2><FONT face=Arial><SPAN 
class=250400003-17062000>-mike</SPAN></FONT></FONT></DIV>
<DIV><FONT size=2><FONT face=Arial><SPAN 
class=250400003-17062000></SPAN></FONT></FONT>&nbsp;</DIV>
<DIV><FONT face=Arial size=2><SPAN 
class=250400003-17062000></SPAN></FONT>&nbsp;</DIV></BODY></HTML>

------_=_NextPart_001_01BFD809.119BE148--


