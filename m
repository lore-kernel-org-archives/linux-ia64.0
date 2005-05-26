From: "Lynch, Rusty" <rusty.lynch@intel.com>
Date: Thu, 26 May 2005 18:23:44 +0000
Subject: RE: [patch] Kprobes ia64 qp fix
Message-Id: <032EB457B9DBC540BFB1B7B519C78B0E073AE2CC@orsmsx404.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505261751.j4QHpjei009076@linux.jf.intel.com>
In-Reply-To: <200505261751.j4QHpjei009076@linux.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: akpm@osdl.org, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>>> On Thu, 26 May 2005 10:51:45 -0700, Rusty Lynch
><rusty.lynch@intel.com> said:
>
>  Rusty> The following patch is for the 2.6.12-rc5-mm1 + my previous
>  Rusty> "Kprobes ia64 cleanup" patch that fixes a bug where a kprobe
still
>  Rusty> fires when the instruction is predicated off.  So given the
p6=0,
>  Rusty> and we have an instruction like:
>
>  Rusty> (p6) move loc1=0
>
>  Rusty> we should not be triggering the kprobe.  This is handled by
>  Rusty> carrying over the qp section of the original instruction into
>  Rusty> the break instruction.
>
>What about:
>
>	(p6) cmp.eq.unc p9,p10=rX,rY
>
>would the code handle that right?  Similary, you may want to check for
>the correct handling of instructions that cannot be predicated (such
>as "cover").
>
>	--david

Thanks, I need to look into this one.  Let me update my test to cover
both of these cases and then take another look at our logic.

    --rusty
