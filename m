From: Robert K Gjertsen <gjertsen@us.ibm.com>
Date: Wed, 29 Jan 2003 15:21:09 +0000
Subject: [Linux-ia64] segv with gas using gcc 3.2
Message-Id: <marc-linux-ia64-105590709805767@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is a multipart message in MIME format.
--=_alternative 0033359286256CBD_Content-Type: text/plain; charset="us-ascii"

I'm seeing gas yak/segv on some assembly code that we use
to avoid pulling extraneous instructions into the
instruction cache (avoid debugging code when debugging is turned off).
This used to work with gcc 2.96 but now dies with gcc 3.2
when optimizations are turned on (-O or higher). I'm trying to reduce this
to a smaller and manageable case and also figure out whether
I'm doing something ill-advised given that we are making
some assumptions on how the code is ordered in the remote
section (works OK on i386 with gcc 3.2).
Just seeing if someone may have some insight on my example below.

Thanks,

--Rob

I use something like the following where the
assembly code before and after is usually a gcc asm
macro for convenience (and this isn't all bundled together
in a gcc asm statement like you see in spinlock.h with read_lock
... perhaps it has to be done that way with IA64),
and this is done numerous times in a particular file.


br.cond.sptk.few 2f
".section .text.trace,"ax
2: 
 
# various instructions for my debugging/tracing code

br.cond.sptk.many 1f
.previous
1:

--=_alternative 0033359286256CBD_Content-Type: text/html; charset="us-ascii"


<br><font size=2 face="Courier New">I'm seeing gas yak/segv on some assembly code that we use</font>
<br><font size=2 face="Courier New">to avoid pulling extraneous instructions into the</font>
<br><font size=2 face="Courier New">instruction cache (avoid debugging code when debugging is turned off).</font>
<br><font size=2 face="Courier New">This used to work with gcc 2.96 but now dies with gcc 3.2</font>
<br><font size=2 face="Courier New">when optimizations are turned on (-O or higher). I'm trying to reduce this</font>
<br><font size=2 face="Courier New">to a smaller and manageable case and also figure out whether</font>
<br><font size=2 face="Courier New">I'm doing something ill-advised given that we are making</font>
<br><font size=2 face="Courier New">some assumptions on how the code is ordered in the remote</font>
<br><font size=2 face="Courier New">section (works OK on i386 with gcc 3.2).</font>
<br><font size=2 face="Courier New">Just seeing if someone may have some insight on my example below.</font>
<br>
<br><font size=2 face="Courier New">Thanks,</font>
<br>
<br><font size=2 face="Courier New">--Rob</font>
<br>
<br><font size=2 face="Courier New">I use something like the following where the</font>
<br><font size=2 face="Courier New">assembly code before and after is usually a gcc asm</font>
<br><font size=2 face="Courier New">macro for convenience (and this isn't all bundled together</font>
<br><font size=2 face="Courier New">in a gcc asm statement like you see in spinlock.h with read_lock</font>
<br><font size=2 face="Courier New">... perhaps it has to be done that way with IA64),</font>
<br><font size=2 face="Courier New">and this is done numerous times in a particular file.</font>
<br>
<br>
<br><font size=2 face="Courier New">br.cond.sptk.few 2f<br>
&quot;.section .text.trace,&quot;ax<br>
2: &nbsp; &nbsp; &nbsp;</font>
<br><font size=2 face="Courier New">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </font>
<br><font size=2 face="Courier New"># various instructions for my debugging/tracing code</font>
<br>
<br><font size=2 face="Courier New">br.cond.sptk.many 1f<br>
.previous<br>
1:</font>
<br>
--=_alternative 0033359286256CBD_=--

