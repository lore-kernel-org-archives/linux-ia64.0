From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 13 May 2005 22:07:27 +0000
Subject: new beta perfmon code base with IA-64/Pentium M/X86-64 support
Message-Id: <20050513220727.GA3560@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello everyone,

I am happy to announce that I have now released a first version of
the new code base for the perfmon subsystem. As of now this is still
beta code and it is not meant for production systems nor any official
kernel. It is primarily targeted at OS and tool developers. 

This new code base follows fairly closely the specification
that was released as an HPLabs technical report (HPL-2004-200R1).
Yet there are a few changes which are not yet reflected in the
published document (I will get to that soon, hopefully).

Among the new features:
	- support for Pentium M processors
	- support for AMD's X86-64 (64-bit mode) processor family

	- support for kernel level event sets
	- support for time-based and overflow-based event set switching
	- support for idle-task exclusion in system-wide mode
	- On IA-64, option to monitor or exclude interrupt-only execution (system-wide)
	- a new portable default sampling format
	- PMU description tables are now kernel modules
	- new config commands: PFM_GETINFO_PMCS, PFM_GETINFO_PMDS
	- new config parameters to control resource usage
	- code is now split between machine independent and dependent

On IA-64, full source AND binary compatibility is retained for existing
pefmon2-based applications. However, it is advised that people should try
and migrate to the new commands and features for portability. The
compatibility support is turned on by default, and can be turned off by
undefining PFM_IA64_PERFMON_COMPAT.  Look in include/asm-ia64/perfmon_compat.h
for migration help. On all other platforms, there is obviously no 
backward compatibility mode.

The set of software features is IDENTICAL on all platforms. That
means that on IA-64, X86-64 and Pentium M, you can benefit from:

	- per-thread and system wide monitoring
	- simple counting and sampling
	- multiple sampling periods
	- kernel level sampling buffer with remapping
	- custom sampling buffer formats via kernel modules
	- message-based overflow notification w/ poll/select support
	- event sets
	- time and overflow-based set switching
	- idle-task exclusion in system-wide
	- randomization of sampling periods

The code for X86-64 and Pentium M is beta and there are certainly
things that can be improved. Both ports are meant as validation
tests for the interface and also as examples of how to add support
for other processors.

It is important to note that the interface to arch-specific
code is not frozen. It can certainly still evolve to accomodate
unforseen arch-specific behaviors. Similarly suggestions
on how to improve the interface are welcome.

The new code based is distributed as a tarball containing a kernel patch
against 2.6.12-rc3 from the (IA-64 test-2.6) GIT repository at kernel.org
and a small porting guide. The patch should be fairly easy to apply to newer
kernels. Being kernel code, the patch is released under the GPL license.

Not being an IA-32 expert myself, I would like to recognize
Mikael Pettersson for his work on perfctr from which some small
pieces of code for X86-64/Pentium M are inspired. I have more or
less used the same hooks and I have certainly tried to minimze
the number of places where hooks are needed. I also put a lot of
effort is trying to keep this as clean as possible. 

I am planning some more cleanups and a couple more features requested
by users.

I hope people will find the multi-platform support useful and will
contribute ports to the other important processors.

You can download the package at:
	ftp://ftp.hpl.hp.com/pub/linux-ia64/perfmon-new-base-050513.tar.gz
	MD5SUM: 24205b9a82e3f5d840b876845cc7edb5

Enjoy,
