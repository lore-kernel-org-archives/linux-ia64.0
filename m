From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 29 Jun 2004 17:40:16 +0000
Subject: RE: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200406291738.i5THcTY13588@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote on Tuesday, June 29, 2004 10:32 AM
> On Tuesday, June 29, 2004 8:34 am, Chen, Kenneth W wrote:
> > To follow up the other bug in head.S, here is the fix.
> >
> > ---------
> > For BP, we are not installing any region 7 DTLB mapping for init_task.
> > However, kr(stack) is being initialized to a legal kernel granule that
> > the kernel resides.  If the first task context switch out of this
> > init_task happens to have its task struct in that very same granule,
> > the stack will not be mapped by any DTLB.  Patch to properly initialize
> > kr(stack) for BP.
>
> I tried both of these on a machine that doesn't have memory at the stock
> kernel load address, and it failed very early on.  However, it works with the
> attached patch.

Let me confirm what I understand:
David's bk tree doesn't boot.
David's bk tree + 2 patches I posted this morning doesn't boot.

Is that correct?


