From: "riedel" <jsriedel@me.nps.navy.mil>
Date: Wed, 25 Oct 2000 02:47:41 +0000
Subject: [Linux-ia64] static registers during a context switch
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_NextPart_000_0004_01C03E04.090B4A20"
Message-Id: <marc-linux-ia64-105590678205620@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_0004_01C03E04.090B4A20
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

hi everybody,
does anybody know what happens to static registers (gr0-gr31) in case of =
a context switch.
in the manual, it says static registers are visible to all procedures(i =
guess it shouldn't otherwise on a context switch another process would =
have the same static registers) On the other hand, stacked registers are =
local to procedures and saved and restored by RSE which makes sense to =
me.

------=_NextPart_000_0004_01C03E04.090B4A20
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD W3 HTML//EN">
<HTML>
<HEAD>

<META content=3Dtext/html;charset=3Diso-8859-1 =
http-equiv=3DContent-Type>
<META content=3D'"MSHTML 4.72.2106.6"' name=3DGENERATOR>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV>
<DIV><FONT color=3D#000000 size=3D2>hi everybody,</FONT></DIV>
<DIV><FONT color=3D#000000 size=3D2>does anybody know what happens to =
static=20
registers (gr0-gr31) in case of a context switch.</FONT></DIV>
<DIV><FONT color=3D#000000 size=3D2>in the manual, it says static =
registers are=20
visible to all procedures(i guess it shouldn't otherwise on a context =
switch=20
another process would have the same static registers) On the other hand, =
stacked=20
registers are local to procedures and saved and restored by RSE which =
makes=20
sense to me.</FONT></DIV></DIV></BODY></HTML>

------=_NextPart_000_0004_01C03E04.090B4A20--


