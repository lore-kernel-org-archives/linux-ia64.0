From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 13 Jun 2006 21:52:51 +0000
Subject: 2.6.17-rc6 new perfmon code base + libpfm available
Message-Id: <20060613215251.GB5407@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfmon@napali.hpl.hp.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, oprofile-list@lists.sourceforge.net, perfctr-devel@lists.sourceforge.net

Hello,

I have released another version of the perfmon new code base package.
This version of the kernel patch is relative to 2.6.17-rc6.

The patch includes:
	- moved all set/multiplexing related code into a dedicated file,
	  name perfmon_sets.c.

	- cleaned a lot of code (for style, dead code)

	- switch all lists to use list.h 

	- fix locking bugs in perfmon_syscalls.c

	- simplified PMU description tables with macros to improve
	  readability and extensibility

	- updated Kconfig structure as per Roman's feedback

	- changed the pfarg_setinfo structure to include 2 new
	  bitfields to report list of available PMU registers

As a consequence of the small API change, you need to update to
libpfm-3.2-060613.

Also new in libpfm-3.2-060613:
	- integrated common code to manage separate event unit masks
	  by Kevin Corry (IBM). With this code we now have an API to
	  handle complicated unit mask combinations on processors such
	  as P4, for instance.

	- updated detect_pmcs.c to use the new pfm_getinfo_evtsets()
	  to retrieve the list of unavalaible pmc registers.

	- updated all examples to use the new detect_pmcs code.

This version of the library ONLY works with 2.6.17-rc6 and higher.


You can grab the new packages at our web site:

	 http://perfmon2.sf.net
-- 
-Stephane
