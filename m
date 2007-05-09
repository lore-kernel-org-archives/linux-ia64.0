From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 09 May 2007 09:27:29 +0000
Subject: 2.6.21 new perfmon code base + libpfm + pfmon
Message-Id: <20070509092729.GC15858@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfmon@napali.hpl.hp.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, oprofile-list@lists.sourceforge.net, perfctr-devel@lists.sourceforge.net, Stephane Eranian <eranian@hpl.hp.com>

Hello,

I have released another version of the perfmon new code base package.
This version of the kernel patch is relative to 2.6.21.

This  new kernel patch includes the following new features and
bug fixes:
	- due to various comments I have dropped the use of the idle_notifier()
	  to stop monitoring during the useless execution of the idle loop. The
	  behavior depends on the HW or firmware, i.e., some events may keep on
	  counting others may stop. Note that both behaviors may be valid and
	  desired based on what users want to measure. For instance, it does
 	  make sense to try and count BUS events when the processor is in
	  mwait/halt.  On IA-64, we provide a way to force a stop with an
	  event set flag. This change prompted a new interface version of 2.4.

	- we expose counter width per PMD in /sys

	- the Opteron PMU description module now enforces Northbridge events
	  restrictions for dual-core processors

	- several PPC updates (Kevin Corry/Carl Love)
	
I have also released a new libpfm, libpfm-3.2-070507, with lots of
changes. Here are some of the most important ones:
	- various MIPS updates (Phil Mucci)
	- support for SciCortex ICE9 PMU (Phil Mucci)
	- framework for PPC support (Kevin Corry)
	- updated Montecito event table
	- independent unit masks for Opteron events above 0x9 (Dan Terpstra)
	- support for Pentium 4 replay tags (Dan Terpstra)
	- updates to pfmsetup (Kevin Corry)
	- many updates to IA-64 examples

Also a new version of pfmon, pfmon-3.2-070507, with lots of changes,including:
	- updated MIPS support (Phil Mucci)
	- many memory leaks and bug fixes (Rysjard Jurga)
	- fix --trigger-code recusion on non-IA64 architectures
	- fixes to symbol resolutions
	- -print-interval is expressed in milliseconds
	- make test programs more portable
	- simplified incremental show result function for --print-interval

In terms of mainline integration, the kernel package includes a base.diff
patch which contains a few infrastructure changes:

	- x86-64 : use PERFCTR1 instead of PERFCTR0 for NMI watchdog for
		   architectural perfmon. This patch is in for 2.6.22
	- i386   : use PERFCTR1 instead of PERFCTR0 for NMI watchdog for
		   architectural perfmon. This patch is in for 2.6.22
	- mips   : add smp_call_function_single()
	- powerpc: add smp_call_function_single()
	- powerpc: make topology_init a subsys_initcall()

All those patches have been provided to top-level architecture maintainers.
I will push the rest (perfmon core, including all arch specific code) for
2.6.23.

Thanks to all the people who have contributed to this release.

You can get the package and very detailed changelogs our the web site:

	 http://perfmon2.sf.net

Enjoy,

-- 
-Stephane
