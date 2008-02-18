From: "Dong, Eddie" <eddie.dong@intel.com>
Date: Mon, 18 Feb 2008 13:58:27 +0000
Subject: RE: paravirt_ops support in IA64
Message-Id: <10EA09EFD8728347A513008B6B0DA77A02C8274B@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <10EA09EFD8728347A513008B6B0DA77A02C8234B@pdsmsx411.ccr.corp.intel.com>
In-Reply-To: <10EA09EFD8728347A513008B6B0DA77A02C8234B@pdsmsx411.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote:
> those should be discussed here.  Also, could you repost the patches?

The work is just started, so sorry we don't have patches in hand right
now.
But we can provide some example code for better reference.

> 
> On a different note, I am willingly and woefully unaware of what the
> paravirt _NEEDS_ are.  Could those be summarised as well?  I will

Sure. In both X86 & IA64, the classical processor architecture is not
virtualizable (before VT and similar HW technology are invented), so
para_virtualization technology is invented by modifying guest Linux
source code to work with hypervisor cooperatively, such as Xen.

But this kind of paravirtualization technology needs to modify Linux
source a lot and get a lot of debate in community. The original
Xen PV patches are not accepted so far and it is a 
big issue to OSVs to maintain 2 version of Linux OS (guest Linux
and bare metal Linux). Meanwhile there are new hypervisors come 
in which need different modification to Linux. VMware proposed 
VMI (Virtual Machine Interface) in 06 OLS to replace sensitive
instructions
by VMI so that same Linux binary can run for both native and guest. 

Later on Rusty Russell proposed a function table based solution called 
paravirt_ops (pv_ops) and eventually get community buy in. Today the
X86/32 bits support is in upstream.

The basic idea of X86 pv_ops is to replace original processor sensitive 
instructions such as cli/sti to a call to a pv_ops function table, whose

contents are initialized for each hypervisor.  For example:

--- xx  2008-02-18 20:09:32.000000000 +0800
+++ entry_32.S  2007-12-18 16:22:59.000000000 +0800
@@ -264,7 +264,7 @@

 #ifdef CONFIG_PREEMPT
 ENTRY(resume_kernel)
-       cli
+       DISABLE_INTERRUPTS(CLBR_ANY)
        cmpl $0,TI_preempt_count(%ebp)  # non-zero preempt_count ?
        jnz restore_nocheck
 need_resched:

	The definition of DISABLE_INTERRUPTS behavior like (pseudo
code):

#define DISABLE_INTERRUPTS(clb)	pv_irq_ops->irq_disable()

	At the Linux startup time, the initialization code will set
pv_irq_ops->irq_disable to xen_irqdisable if underlying hyperviosr is
Xen,
native_irqdisable if on bare metal for example.


> admit to being completely ignorant about how paravirt works on x86.
> Please don't state them in terms of we want to change the code this
> way, but rather in terms of we need to intercept these points in the
> kernel for this reason/purpose.

Agree, basically IA64 side has same maintenance issue for OSVs
such as Redhat to release 2 images for native & Xen guest today. 
to be more important, today Xen PV (paravirtualized) guest only support
2.6.18 Linux, forward porting to latest Linux needs a lot of effort. So
we want to push those changes to upstream. That is the whole purpose.

People ever pushed current Xen/IA64 PV Linux changes to upstream, 
but didn't get promising result yet. Due to the ermeging pv_ops support
in X86 side, if IA64 side also takes pv_ops based solution, we can reuse
a lot of common code and thus less patch than before. It also can
support
 different hypervisor in future easily such as KVM for
paravirtualization. 

Current Xen/IA64 is not doing pv_ops yet, we are still in brainstorming/
design phase. If we could get more comments from you guys before we 
choose a way to go, that would save us a lot of effort. 

Yes, right now we are mainly focusing on entry.S & ivt.S changes.

> 
> Thanks,
> Robin
> -
Thanks, Eddie
