From: "Mike Fox" <mfox@annapmicro.com>
Date: Tue, 08 Apr 2003 21:59:56 +0000
Subject: [Linux-ia64] mmap crashes system after mapping PCI device into user space and reading and writing.
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_NextPart_000_0020_01C2FDF8.AA4069A0"
Message-Id: <marc-linux-ia64-105590723705441@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_0020_01C2FDF8.AA4069A0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi,

=20

I am running kernel version 2.4.19 and I am getting a system crash when =
I
mmap my PCI device into user space and access it.

=20

It seems to be the same issue that was posted earlier in the following =
post,
which had no response:

=20

Has anyone tried using mmap to remap PCI device memory into user space?  =
I
have seen the following problem:  If I do the mmap, it returns =
successfully,
and I can indeed access the device memory.  Unfortunately, the system =
will
hang within about a minute after doing so.  I do not get an oops, or =
crash
of any kind, simply no further response form the machine.  If I just do =
the
mmap and then munmap the system will not hang.  But if I do one access =
to
the mmapped address, the system will hang.  I am using the =
remap_page_range
call in my mmap routine, and this same code works on x86 and Alpha
platforms.  I found it odd that it takes a while for the system to hang
after the access, is their something special I have to do for this to =
work
on IA64?  I am running 2.4.1 with the 1/31 patch, although this problem
occurs on all previous kernels I have tried.  Thanks in advance for any
insight anyone might have.

=20

Thanks for any help you can give. I'm new to Linux and IA64 and I am in =
a
rush to port a PCI driver and API.

=20

Thanks,

Mike Fox.

=20

=20


------=_NextPart_000_0020_01C2FDF8.AA4069A0
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html>

<head>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">


<meta name=3DGenerator content=3D"Microsoft Word 10 (filtered)">

<style>
<!--
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:12.0pt;
	font-family:"Times New Roman";}
a:link, span.MsoHyperlink
	{color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{color:purple;
	text-decoration:underline;}
pre
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:10.0pt;
	font-family:"Courier New";}
span.EmailStyle17
	{font-family:Arial;
	color:windowtext;}
@page Section1
	{size:8.5in 11.0in;
	margin:1.0in 1.25in 1.0in 1.25in;}
div.Section1
	{page:Section1;}
-->
</style>

</head>

<body lang=3DEN-US link=3Dblue vlink=3Dpurple>

<div class=3DSection1>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Hi,</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>I am running kernel version 2.4.19 and I am getting a =
system
crash when I mmap my PCI device into user space and access =
it.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>It seems to be the same issue that was posted earlier =
in the
following post, which had no response:</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<pre><font size=3D2 face=3D"Courier New"><span =
style=3D'font-size:10.0pt'>Has anyone tried using mmap to remap PCI =
device memory into user space?&nbsp; I</span></font></pre><pre><font
size=3D2 face=3D"Courier New"><span style=3D'font-size:10.0pt'>have seen =
the following problem:&nbsp; If I do the mmap, it returns =
successfully,</span></font></pre><pre><font
size=3D2 face=3D"Courier New"><span style=3D'font-size:10.0pt'>and I can =
indeed access the device memory.&nbsp; Unfortunately, the system =
will</span></font></pre><pre><font
size=3D2 face=3D"Courier New"><span style=3D'font-size:10.0pt'>hang =
within about a minute after doing so.&nbsp; I do not get an oops, or =
crash</span></font></pre><pre><font
size=3D2 face=3D"Courier New"><span style=3D'font-size:10.0pt'>of any =
kind, simply no further response form the machine.&nbsp; If I just do =
the</span></font></pre><pre><font
size=3D2 face=3D"Courier New"><span style=3D'font-size:10.0pt'>mmap and =
then munmap the system will not hang.&nbsp; But if I do one access =
to</span></font></pre><pre><font
size=3D2 face=3D"Courier New"><span style=3D'font-size:10.0pt'>the =
mmapped address, the system will hang.&nbsp; I am using the =
remap_page_range</span></font></pre><pre><font
size=3D2 face=3D"Courier New"><span style=3D'font-size:10.0pt'>call in =
my mmap routine, and this same code works on x86 and =
Alpha</span></font></pre><pre><font
size=3D2 face=3D"Courier New"><span =
style=3D'font-size:10.0pt'>platforms.&nbsp; I found it odd that it takes =
a while for the system to hang</span></font></pre><pre><font
size=3D2 face=3D"Courier New"><span style=3D'font-size:10.0pt'>after the =
access, is their something special I have to do for this to =
work</span></font></pre><pre><font
size=3D2 face=3D"Courier New"><span style=3D'font-size:10.0pt'>on =
IA64?&nbsp; I am running 2.4.1 with the 1/31 patch, although this =
problem</span></font></pre><pre><font
size=3D2 face=3D"Courier New"><span style=3D'font-size:10.0pt'>occurs on =
all previous kernels I have tried.&nbsp; Thanks in advance for =
any</span></font></pre><pre><font
size=3D2 face=3D"Courier New"><span style=3D'font-size:10.0pt'>insight =
anyone might have.</span></font></pre>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Thanks for any help you can give. I&#8217;m new to =
Linux and
IA64 and I am in a rush to port a PCI driver and API.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Thanks,</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>Mike Fox.</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

</div>

</body>

</html>

------=_NextPart_000_0020_01C2FDF8.AA4069A0--


