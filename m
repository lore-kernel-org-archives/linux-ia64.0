From: Robert K Gjertsen <gjertsen@us.ibm.com>
Date: Mon, 17 Mar 2003 21:03:37 +0000
Subject: [Linux-ia64] question on stabs option being disabled with ia64
Message-Id: <marc-linux-ia64-105590709806138@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806141@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806141@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is a multipart message in MIME format.
--=_alternative 00528CE486256CEC_Content-Type: text/plain; charset="us-ascii"

I was wondering if someone could provide some insight on why
the stabs support for ia64 was disabled in gcc 3.1.
My understanding is that DWARF2 is the default debugging format on 
ia64-linux,
yet it was once possible to configure ia64 gcc to use stabs instead of
DWARF2, and it's still possible to use stabs on i686-linux and 
powerpc64-linux.

This is motived by my interest in LKCD, which depends on stabs.
I'm trying to determine whether it will take more work to fix ia64 gcc
or make LKCD use DWARF2 with ia64 (for lcrash) and would appreciate any
pointers.
KDB is fine for in-house debugging, but it isn't the preferred method on
customer systems.

Thanks,

--Rob
--=_alternative 00528CE486256CEC_Content-Type: text/html; charset="us-ascii"


<br><font size=2 face="Courier New">I was wondering if someone could provide some insight on why</font>
<br><font size=2 face="Courier New">the stabs support for ia64 was disabled in gcc 3.1.</font>
<br><font size=2 face="Courier New">My understanding is that DWARF2 is the default debugging format on ia64-linux,</font>
<br><font size=2 face="Courier New">yet it was once possible to configure ia64 gcc to use stabs instead of</font>
<br><font size=2 face="Courier New">DWARF2, and it's still possible to use stabs on i686-linux and powerpc64-linux.</font>
<br>
<br><font size=2 face="Courier New">This is motived by my interest in LKCD, which depends on stabs.</font>
<br><font size=2 face="Courier New">I'm trying to determine whether it will take more work to fix ia64 gcc</font>
<br><font size=2 face="Courier New">or make LKCD use DWARF2 with ia64 (for lcrash) and would appreciate any</font>
<br><font size=2 face="Courier New">pointers.</font>
<br><font size=2 face="Courier New">KDB is fine for in-house debugging, but it isn't the preferred method on</font>
<br><font size=2 face="Courier New">customer systems.</font>
<br>
<br><font size=2 face="Courier New">Thanks,</font>
<br>
<br><font size=2 face="Courier New">--Rob</font>
--=_alternative 00528CE486256CEC_=--

