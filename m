From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 22 Oct 2007 09:44:01 +0000
Subject: 2.6.23 new perfmon code base + libpfm + pfmon
Message-Id: <20071022094401.GB26741@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfmon@napali.hpl.hp.com
Cc: Stephane Eranian <eranian@hpl.hp.com>, oprofile-list@lists.sourceforge.net, linux-kernel@vger.kernel.org, perfctr-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

Hello,

I have released another version of the perfmon new code base package.
This version of the kernel patch is relative to 2.6.23. This is the first
release based on the perfmon git tree from kernel.org. The structure of
the package has changed, only one diff file to apply now.

This new patch introduces perfmon2 v2.7.  There were many other changes
which are highlighted below:

This  new kernel patch includes the following new features and
bug fixes:
	- full support for AMD Family 10h (Barcelona) processors,
	  including the new Instruction-Based Samplig (IBS) feature.
	  This is the work of Robert Richter (AMD).

	- support for AMD K7 (Jeff Muizelaar)

	- Several Cell processor updates from Kevin Corry (IBM),
	  Takaki Azuma (Toshiba), Takayuki Uchikawa (Toshiba)

	- Important rework of PEBS support for Pentium 4 and Intel Core
	  based processors. Basically the PEBS support is now split between
	  the two processor families due to incompatbilities when running
	  in 32-bit mode. As a consequence, there are two distinct
	  sampling formats with two distinct header files: perfmon_pebs_p4_smpl.h
	  and perfmon_pebs_core_smpl.h. The corresponding data structures
	  have been renamed as well. There is no functionality changes.

	- ensure we do not set unimplemented PMD bits

	- fix multiple pfm_restart() call issues

	- fix several important register mapping table errors in perfmon_intel_arch.c
 	  used with architectural PMU v1 and v2 when nothing else works.
	  The fixed counters were not correctly numbered.

	- take Intel Core Duo errata AE49 into account (only one enable bit).

	- fix several issues and races with the PMU acquire/release mechanism

	- allow non counting PMD registers to have OVFL_NOTIFY, RANDOM set.
	  The corrolary being that perfmon now does not assume that only counters
	  can generate interrupts (required for AMD IBS)

	- do not report errors on a per vector element basis for all syscalls
	  accepting vector arguments (pfm_*pm*(), for instance). Simplifies
	  the code and provide some performance boost

	- various code cleanups (trailing spaces, indentations)

Some remark about IBS: IBS uses the extended interrupt feature of AMD
Barcelona. Setting them up requires two steps: pci config space peeking
and poking, and actual extended APIC writes. The first step is currently
done by the perfmon AMd64 description module. There is ongoing work by
Robert to push this in the general kernel initialization path for 2.6.24.

I have also released a new libpfm, libpfm-3.2-071017, with several
exciting changes. Here are some of the most important ones:

	- support for PPC64 processors (PPC970{FX,GX,MP},POWER{4,4+,5,5+,6}).
	  Corey Ashford (IBM)

	- support for Cell processor. Yoshio Funayama, Takayuki Uchikawa (Toshiba)

	- update to match perfmon2 v2.7, includes PEBS examples

	- Various Cray updates. Steve Kaufmann (Cray)

	- important updates to Intel Core event tables. New event RS_UOPS_DISPATCHED_CYCLES
	  and bug fixes for many other important events.

	- rewrite amd64 cpuid() routine to be universal i386/x86_64 PiC/noPiC.
	  Dan Terpstra (U. of Tennessee)

	- several initialization bugs fixes. Eric Paris (Redhat)

IMPORTANT: this version of the library ONLY works with 2.6.23 (due to syscall number changes).

Also a new version of pfmon, pfmon-3.2-071017, with several important improvements:

	- initial Cell support. Takashi Yamamoto (Sony)

	- switch to libstdc++ for symbol name demangling

	- performance improvement to symbol table parsing and searching

	- --print-interval does not print final totoal anymore (was confusing)

	- --smpl-show-top, --smpl-ignore-pids, --smpl-show-function promoted as global options

	- improved inst-hist (default) sampling format to support multiple sampling periods

	- profiles print both code addresses and symbolic names

IMPORTANT: you need libpfm-3.2-071017 with this release of pfmon

You can get the package and very detailed changelogs our the web site:

	 http://perfmon2.sf.net

Due to Sourceforge shell access problems, the main page could not be updated at this point.
Go to 'Project Files' to grab the new packages.

Enjoy,

-- 
-Stephane
