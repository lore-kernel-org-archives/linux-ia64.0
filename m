From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 18 Oct 2005 04:15:56 +0000
Subject: updated perfmon new code base package available
Message-Id: <20051018041556.GJ3614@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfmon@napali.hpl.hp.com
Cc: perfctr-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hello everyone,

I have released an updated version of the perfmon new code base package.
This release is relative to 2.6.14-rc4-mm1. I have also updated the library,
libpfm-3.2, to match the kernel level changes.

Kernel-package features:
------------------------
	- preliminary support for MIPS R5000 by Phil Mucci
	- on X86-64, P6, P4 32-bits, the PMC enable bits are now
	  under the control of the users. Pfm_start/pfm_stop do not
	  touch them anymore. That means applications must set them.
	- simplified arch-specific interface (merged calls)
	- simplified PMU description tables (removed dep_pmc[])

I now have a compilation environment for PPC64 and MIPS64, as such
I have verified that the patches for those architectures compile,
no actual testing has been done, though.

For MIPS, the patch is relative to the www.linux-mips.org GIT
tree as they still maintain a separate tree. The common perfmon
patch does apply cleanly even though the MIPS tree is sligthly
behind (see README.mips).

For libpfm-3.2, the updates is to reflect the changes for the
enable bits for P6, X86-64. The P4 standalone programs, and
PEBS examples have also been  updated for enable bits. Note
that the PEBS support does not seem to work when Hyperthreading
is enabled. I have not yet tracked this one down, any volunteer?

You can grab both packages at our SourceForge web site:
	
	http://www.sf.net/projects/perfmon2

You must download:
	- 2.6.14-rc4-mm1-051017
	- libpfm-3.2-051018

Enjoy,

-- 
-Stephane
