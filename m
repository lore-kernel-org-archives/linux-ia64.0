From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 07 Mar 2003 19:22:27 +0000
Subject: Re: [Linux-ia64] Re: [patch] 2.4.20 unwind.c to handle multiple struct pt_regs
Message-Id: <marc-linux-ia64-105590709806003@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805882@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805882@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 04 March 2003 3:06 pm, David Mosberger wrote:
> >>>>> On Thu, 20 Feb 2003 12:29:20 +1100, Keith Owens <kaos@sgi.com> said:
> 
>   Keith> Two patches follow.  The first updates include/asm-ia64/unwind.h,
>   Keith> arch/ia64/kernel/unwind_i.h, arch/ia64/kernel/unwind.c to handle
>   Keith> multiple pt_regs on stack.  The second only updates unwind.c, it goes
>   Keith> over the first patch to clean up the debug code, using UNW_DPRINT().
> 
> I applied most of these two patches now.  I omitted the portions where
> you turned error messages into debug statements.  Also, I'm going to
> change dump_info_pt() into something more reasonable.

I applied these patches to 2.4 also:

ChangeSet@1.1009.1.16, 2003-03-07 12:02:17-07:00, davidm@tiger.hpl.hp.com
  ia64: In kernel unwinder, replace dump_info_pt() with get_scratch_regs()
        and reformat to make it fit in 100 columns.

ChangeSet@1.1009.1.15, 2003-03-07 12:02:07-07:00, davidm@tiger.hpl.hp.com
  ia64; Improve debug output from kernel unwinder.  Based on patch by
        Keith Owens.  (Ported to 2.4 by Bjorn Helgaas).

ChangeSet@1.1009.1.14, 2003-03-07 12:01:27-07:00, kaos@sgi.com
  [PATCH] ia64: fix scratch-regs handling in kernel unwinder
  
  This patch has been running inside SGI for 2 months.  It
  handles kernel stacks with multiple struct pt_regs, as found
  while debugging the kernel.



