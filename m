From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 21 Jun 2006 14:24:47 +0000
Subject: 2.6.17.1 new perfmon code base, libpfm, pfmon available
Message-Id: <20060621142447.GA29389@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfmon@napali.hpl.hp.com
Cc: perfctr-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, oprofile-list@lists.sourceforge.net

Hello,

I have released another version of the perfmon new code base package.
This version of the kernel patch is relative to 2.6.17.1.

The patch includes:
	- support for 32-bit mode AMD64 processors (Chuck Ebbert)
	- mini-argument buffers on stack optimization for read/write of PMU registers
	- fix user group permission checking which were ignored
	- fix a missing irqsave in perfmon_kapi.c

For the stack buffers there are per-arch constants that can be adjusted based
on stack size limitations. Look for PFM_ARCH_PM*_ARG.

I have also release a new libpfm, libpfm-3.2-060621, which includes:

	- support for 32-bit mode AMD64 processors
	- fix an opcode matching/range restriction limitation for Itanium2 PMC13
 	  and Montecito PMC41 registers.

This version of the library works with 2.6.17-rc6 and 2.6.17.1

Also a new version of pfmon, pfmon-3.2-060621, to take advantage of the update in libpfm:

	- support for 32-bit mode AMD64 processors
	- updated event name parsing to prepare for separate
	  event unit mask management (Kevin Corry)
	- fix the detection of unavailable PMC registers. it was causing crashes
	  when used with sampling.

Note that I have tested 32-bit compiled libpfm,pfmon running on an 64-bit AMD
perfmon kernel. I have not tested on a 32-bit AMD linux kernel because I don't
have such setup. I would appreciate any feedback on this.

You can grab the new packages at our web site:

	 http://perfmon2.sf.net

PS: I will post an incremental kernel patch and a diffstat on the perfmon mailing list.

-- 
-Stephane
