From: "Dai, Yiyang" <yiyang.dai@hp.com>
Date: Tue, 29 Oct 2002 01:23:10 +0000
Subject: Re: [Linux-ia64] build a bootable kernel
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C27EE9.BE2B3357"
Message-Id: <marc-linux-ia64-105590709805281@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805272@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805272@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C27EE9.BE2B3357
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable


>On Mon, Oct 28, 2002 at 05:42:59PM +0800, dai yiyang wrote:
>> thanks for your help
>> the kernel file has been built .
>> but how to load the kernel during system boot time ?
>> I have edit the elilo.conf file add the new kernel's path . but the=20
>> the system halted at "umcompressed kernel ......ok ."
>>=20
>What kind of machine are you trying to boot?

   I use a compaq proliant DL590 ( Itanium -700Mhz)

>What is the .config file used to build the kernel?
     =20
   I dont have the experience on build a ia64 kernel , so I use the
common config=20
   My concern is in "IA-64 System type" wehther I should choose
DIG-compliant or generic=20
   I use generic in my kernel configuration
=20
>What is the content of elilo.conf?
           image=3Dvmlinuz-2.5.39
		label=3Dlinux-2.5.39
		initrd=3Dinitrd-2.5.39.img
		read-only
		root=3D/dev/ida/c0d0p3

     the section for my new kernel was copied from my previous kernel
section , I think it should be correct.
>
>With this information I may be able to tell you what's wrong.
>
>Thanks.

>--=20
>-Stephane


------_=_NextPart_001_01C27EE9.BE2B3357
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.0.6249.1">
<TITLE> Re: [Linux-ia64] build a bootable kernel</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/rtf format -->
<BR>

<P><FONT SIZE=3D2 FACE=3D"Arial">&gt;On Mon, Oct 28, 2002 at 05:42:59PM =
+0800, dai yiyang wrote:</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&gt;&gt; thanks for your help</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&gt;&gt; the kernel file has been =
built .</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&gt;&gt; but how to load the kernel =
during system boot time ?</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&gt;&gt; I have edit the elilo.conf =
file add the new kernel's path . but the </FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&gt;&gt; the system halted at =
&quot;umcompressed kernel ......ok .&quot;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&gt;&gt; </FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&gt;What kind of machine are you =
trying to boot?</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp; I use a compaq proliant =
DL590 ( Itanium -700Mhz)</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">&gt;What is the .config file used to =
build the kernel?</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp; I dont have the =
experience on build a ia64 kernel , so I use the common config </FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp; My concern is in =
&quot;IA-64 System type&quot; wehther I should choose DIG-compliant or =
generic </FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp; I use generic in my =
kernel configuration</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&gt;What is the content of =
elilo.conf?</FONT>

<BR><FONT SIZE=3D2 =
FACE=3D"Arial">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p; image=3Dvmlinuz-2.5.39</FONT>

<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <FONT SIZE=3D2 =
FACE=3D"Arial">label=3Dlinux-2.5.39</FONT>

<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <FONT SIZE=3D2 =
FACE=3D"Arial">initrd=3Dinitrd-2.5.39.img</FONT>

<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <FONT SIZE=3D2 =
FACE=3D"Arial">read-only</FONT>

<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <FONT SIZE=3D2 =
FACE=3D"Arial">root=3D/dev/ida/c0d0p3</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp;&nbsp; the section =
for my new kernel was copied from my previous kernel section , I think =
it should be correct.</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&gt;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&gt;With this information I may be =
able to tell you what's wrong.</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&gt;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&gt;Thanks.</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">&gt;-- </FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&gt;-Stephane</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C27EE9.BE2B3357--

