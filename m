From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 13 Feb 2007 18:48:39 +0000
Subject: 2.6.20 new perfmon code base + libpfm + pfmon
Message-Id: <20070213184839.GC10031@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfmon@napali.hpl.hp.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, oprofile-list@lists.sourceforge.net, eranian@hpl.hp.com, perfctr-devel@lists.sourceforge.net

Hello,

I have released another version of the perfmon new code base package.
This version of the kernel patch is relative to 2.6.20.

This  new kernel patch includes the following new features and
bug fixes:
	- first cut at supporting Oprofile on i386 and x86-64 architectures
	- several internal interfaces simplfications
	- various MIPS updates (Phil Mucci/Manoj Ekbote)
	- varous PPC32 updates (Phil Mucci)
	- fix bug in set switching with a single set
	- fix bug in pfm_restart() for per-thread mode with blocking notification

Unfortunately, this release does not build for PowerPC due to a problem with the
TIF_* flags. Perfmon adds 2 new flags which make the TIF now use more than 16 bits which
causes problem with some assembly instructions in entry_64.S. Hopefully,
this will be fixed in the next release.

To make Oprofile work, you need a modified user level Oprofile package. I have made
a first pass at modifying 0.9.2 to work on Perfmon 2.3 (and v2.0 for IA-64) for
the following processors: AMD Opteron, P6, Core Duo, Core 2 Duo, P4. The modified
package is available as Alpha at:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/oprof-perfmon2-070122.diff

I have also released a new libpfm, libpfm-3.2-070206, with lots of
changes. Here are some of the most important ones:
	- Full Intel Core 2 Duo event table (Thanks to Dan Terpstra for his help)
	- Full event table for P6 and Pentium M (Dan Terpstra)
	- various MIPS updates (Phil Mucci)
	- improved Montecito event->counter assignment routine
   	- rewritten P6 event->counter assignment routine
   	- extended detect_unavail_pmcs() code to handle pmds
   	- extended whichpmu.c example to show implement vs.  available registers
	- possiblity to force a libpfm PMU different from host PMU
   	- several bug fixes to library and examples

Also a new version of pfmon, pfmon-3.2-070206, with a few changes:
	- rewritten the automatic sampling buffer sizing based on
     	  the resource limits (rlimits) and perfmon global settings
   	- Intel Core 2 Duo event listing now shows if event supports PEBS
   	- fixed important memory leak that showed up when monitoring across fork/pthread
	
You can get the packages and more detailed changelogs our the web site:

	 http://perfmon2.sf.net (go to Project Files)

Enjoy,

PS: home page not yet updated due to a problem connecting via ssh to SF.net today.

-- 

-Stephane
