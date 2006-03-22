From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 22 Mar 2006 17:29:00 +0000
Subject: 2.6.16 perfmon2 new code base + libpfm available
Message-Id: <20060322172900.GH25650@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfmon@napali.hpl.hp.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, perfctr-devel@lists.sourceforge.net

Hello,

I have released another version of the perfmon new base package.
This release is relative to 2.6.16

There was not system call changes. As such the previous libpfm
dated 060308 should continue to work. However I have also released
on update to libpfm, see below.

This new kernel patch includes several changes:

	- updated IA-64 Oprofile support to work with perfmon v2.2
	  (Will Cohen from RedHat)

	- lots of code cleanups and re-formatting
	  (Kevin Corry from IBM)

	- fix potential fd leak in context create
	  (Kevin Corry from IBM)

	- fixed PEBS for 32-bit P4/Xeon. Was refusing to write PMC63

	- updated PEBS/HT detection in perfmon_p4 and perfmon_em64t

	- fixed PFM_WRITE_PMCS problems in IA-64 compatibility layer. 

The MIPS patches have been omitted from this release because I had troubles
with their GIT repository and my cross-build machine also had problems. MIPs
should be back in the next release.

This releases uses a different breakdown for the patches. For each component
(common, ia64, i386, x86-64, powerpc), the patch is split between new
and modified files. This makes it easier for MIPS which uses a non official
tree. Given that MIPS is not part of this release, you could simply
do a:
	cat ../perfmon-new-base-060322/*.diff | patch -p1 

to apply everything.


The new version of the library, libpfm, includes the following changes:

	- updated the PEBS examples to work on SMP host. PEBS does not
	  work only when HT is enabled

	- Due to popular demand, I have added a new example to show how
	  one can easily build a user library to handle  system-wide monitoring
	  in SMP without having to write a multi-threaded tool. The example
	  includes a first cut at such a library, called libpfms, and simple
	  counting example. The library is multi-threaded, the example is not.

	- fixed showreginfo to look for the right file in /sys/kernel/perfmon.
	  Also remove the extraneous fclose() which was cuasing glibc assertions.

The two packages can be downloaded from the SourceForge website at:

	http://www.sf.net/projects/perfmon2


The SF.net CVS tree has been erased for now. It will be recreated with a more
practical layout.

Enjoy,

-- 
-Stephane
