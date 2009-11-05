From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 05 Nov 2009 23:10:01 +0000
Subject: Re: why ms->pmsa_xip is used?
Message-Id: <12367.1257462601@ocs14w>
List-Id: <linux-ia64.vger.kernel.org>
References: <F6CA51BB11EE80indou.takao@jp.fujitsu.com>
In-Reply-To: <F6CA51BB11EE80indou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 05 Nov 2009 17:53:41 -0500, 
Takao Indoh <indou.takao@jp.fujitsu.com> wrote:
>Now I think it's better to keep it as-is, I mean, use
>pmsa_{xip,xpsr,xfs} if PSR.ic is 0. Instead of that, I'd like to
>save pmsa_{iip,ipsr,ifs} somewhere for debugging. For example,
>
>diff -Nurp a/arch/ia64/include/asm/mca.h b/arch/ia64/include/asm/mca.h
>--- a/arch/ia64/include/asm/mca.h	2009-10-22 12:28:07.000000000 -0400
>+++ b/arch/ia64/include/asm/mca.h	2009-11-03 17:01:33.000000000 -0500
>@@ -106,6 +106,11 @@ struct ia64_sal_os_state {
> 	unsigned long		os_status;		/* OS status to SAL, enum below */
> 	unsigned long		context;		/* 0 if return to same context
> 							   1 if return to new context */
>+
>+	/* I-resources */
>+	unsigned long		iip;
>+	unsigned long		ipsr;
>+	unsigned long		ifs;
> };
> 
> enum {
>diff -Nurp a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
>--- a/arch/ia64/kernel/mca.c	2009-10-22 12:28:07.000000000 -0400
>+++ b/arch/ia64/kernel/mca.c	2009-11-05 11:10:45.000000000 -0500
>@@ -888,9 +888,10 @@ ia64_mca_modify_comm(const struct task_s
> }
> 
> static void
>-finish_pt_regs(struct pt_regs *regs, const pal_min_state_area_t *ms,
>+finish_pt_regs(struct pt_regs *regs, struct ia64_sal_os_state *sos,
> 		unsigned long *nat)
> {
>+	const pal_min_state_area_t *ms = sos->pal_min_state;
> 	const u64 *bank;
> 
> 	/* If ipsr.ic then use pmsa_{iip,ipsr,ifs}, else use
>@@ -904,6 +905,10 @@ finish_pt_regs(struct pt_regs *regs, con
> 		regs->cr_iip = ms->pmsa_xip;
> 		regs->cr_ipsr = ms->pmsa_xpsr;
> 		regs->cr_ifs = ms->pmsa_xfs;
>+
>+		sos->iip = ms->pmsa_iip;
>+		sos->ipsr = ms->pmsa_ipsr;
>+		sos->ifs = ms->pmsa_ifs;
> 	}
> 	regs->pr = ms->pmsa_pr;
> 	regs->b0 = ms->pmsa_br0;
>(snip)
>
>Any idea or comments?

Looks good to me.

