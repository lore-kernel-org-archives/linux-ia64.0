From: William Cohen <wcohen@redhat.com>
Date: Fri, 28 Oct 2005 19:11:40 +0000
Subject: Re: [Perfctr-devel] updated perfmon new code base package available
Message-Id: <436277EC.8040407@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051018041556.GJ3614@frankl.hpl.hp.com>
In-Reply-To: <20051018041556.GJ3614@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: eranian@hpl.hp.com
Cc: perfmon@napali.hpl.hp.com, perfctr-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Stephane Eranian wrote:
> Hello everyone,
> 
> I have released an updated version of the perfmon new code base package.
> This release is relative to 2.6.14-rc4-mm1. I have also updated the library,
> libpfm-3.2, to match the kernel level changes.
> 
> Kernel-package features:
> ------------------------
> 	- preliminary support for MIPS R5000 by Phil Mucci
> 	- on X86-64, P6, P4 32-bits, the PMC enable bits are now
> 	  under the control of the users. Pfm_start/pfm_stop do not
> 	  touch them anymore. That means applications must set them.
> 	- simplified arch-specific interface (merged calls)
> 	- simplified PMU description tables (removed dep_pmc[])
> 
> I now have a compilation environment for PPC64 and MIPS64, as such
> I have verified that the patches for those architectures compile,
> no actual testing has been done, though.
> 
> For MIPS, the patch is relative to the www.linux-mips.org GIT
> tree as they still maintain a separate tree. The common perfmon
> patch does apply cleanly even though the MIPS tree is sligthly
> behind (see README.mips).
> 
> For libpfm-3.2, the updates is to reflect the changes for the
> enable bits for P6, X86-64. The P4 standalone programs, and
> PEBS examples have also been  updated for enable bits. Note
> that the PEBS support does not seem to work when Hyperthreading
> is enabled. I have not yet tracked this one down, any volunteer?
> 
> You can grab both packages at our SourceForge web site:
> 	
> 	http://www.sf.net/projects/perfmon2
> 
> You must download:
> 	- 2.6.14-rc4-mm1-051017
> 	- libpfm-3.2-051018
> 
> Enjoy,
> 


Hi Stephane,

I have been looking at what changes are required to get oprofile to be 
able to use the custom sampling format in perfmon2. It looks like there 
have been some changes between the perfmon and perfmon2. The ia64 
oprofile support uses the older interface. I don't have easy access to 
an ia64 machine, so I have been making similar support available on the 
x86 version.

I noticed that the older interface passed in "struct pt_regs *regs", but 
the newer interface does not. The oprofile code extracted the program 
counter and whether the interrupted process was in kernel or user mode 
from regs. The newer perfmon interface passes in the instruction 
pointer, but the information about user/kernel mode is lacking.

Reading through the perform2 documentation the last argument passed into 
fmt_handler is a void pointer. The Perfmon2 specification 
(HPL-2004-200R1.pdf) says:

data : a pointer to an implementation-specific data structure which may 
be needed by a handler. For instance, this could point to the 
interrupted machine state and/or the thread to which the overflow is 
attributed.

However, the actual call in linux/perfmon/perfmon.c just passes NULL for 
it. Would it be possible to pass the regs instead? Why not pass regs to 
the handler? Was there some thought to allow other data to be passed?

-Will
