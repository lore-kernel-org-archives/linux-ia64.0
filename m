From: "Reese Faucette" <reese@myri.com>
Date: Wed, 06 Nov 2002 00:39:27 +0000
Subject: [Linux-ia64] IA64 strncpy in 2.2.4-30 - bug and patch
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_NextPart_000_003A_01C284E9.E84CD130"
Message-Id: <marc-linux-ia64-105590709805337@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_003A_01C284E9.E84CD130
Content-Type: multipart/alternative;
	boundary="----=_NextPart_001_003B_01C284E9.E84CD130"


------=_NextPart_001_003B_01C284E9.E84CD130
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi,
I opened a bug with RedHat about a problem with strncpy() in =
glibc-2.2.4-30 on IA64, see =
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D76952, but I've =
been told you folks are really the ones to talk to.

The bug report contains a testcase illustrating the problem, and also a =
patch.  In short, the recovery code is busted, even after the patch from =
David Mosberger.  Attached is a copy of the patch from the bug report.

I have a testcase which exercizes both the recovery3 and recovery4 paths =
if you're interested. =20
Regards,
-reese faucette



------=_NextPart_001_003B_01C284E9.E84CD130
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2719.2200" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Hi,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>I opened a bug with RedHat about a =
problem with=20
strncpy() in glibc-2.2.4-30 on IA64, see <A=20
href=3D"https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D76952">htt=
ps://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D76952</A>,=20
but I've been told you folks are really the ones to talk =
to.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>The bug report contains a testcase =
illustrating the=20
problem, and also a patch.&nbsp; In short, the recovery code is busted, =
even=20
after the patch from David Mosberger.&nbsp; Attached is a copy of the =
patch from=20
the bug report.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I have a testcase which exercizes both =
the=20
recovery3 and recovery4 paths if you're interested.&nbsp; </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Regards,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>-reese faucette</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV></BODY></HTML>

------=_NextPart_001_003B_01C284E9.E84CD130--

------=_NextPart_000_003A_01C284E9.E84CD130
Content-Type: application/octet-stream;
	name="strncpy.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="strncpy.patch"

--- strncpy.S	Thu Oct 31 15:19:46 2002=0A=
+++ new/strncpy.S	Thu Oct 31 17:11:34 2002=0A=
@@ -214,11 +214,11 @@=0A=
 	ld8	r[0] =3D [tmp]=0A=
 	br.cond.sptk .back2=0A=
 .recovery3:=0A=
-	add	tmp =3D -MEMLAT * 8, src ;;=0A=
+	add	tmp =3D -(MEMLAT+1) * 8, src ;;=0A=
 	ld8	r[MEMLAT] =3D [tmp]=0A=
 	br.cond.sptk .back3=0A=
 .recovery4:=0A=
-	add	tmp =3D -(MEMLAT - 1) * 8, src ;;=0A=
+	add	tmp =3D -(MEMLAT) * 8, src ;;=0A=
 	ld8	r[MEMLAT - 1] =3D [tmp]=0A=
 	br.cond.sptk .back4=0A=
 END(strncpy)=0A=

------=_NextPart_000_003A_01C284E9.E84CD130--


