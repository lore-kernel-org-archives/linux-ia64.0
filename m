From: Takao Indoh <indou.takao@jp.fujitsu.com>
Date: Thu, 05 Nov 2009 22:53:41 +0000
Subject: Re: why ms->pmsa_xip is used?
Message-Id: <31CA5E6AD23329indou.takao@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <F6CA51BB11EE80indou.takao@jp.fujitsu.com>
In-Reply-To: <F6CA51BB11EE80indou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, 27 Oct 2009 18:21:11 -0400, Takao Indoh wrote:

>On Tue, 27 Oct 2009 10:36:53 +1100, Keith Owens wrote:
>
>>On Mon, 26 Oct 2009 18:15:22 -0400,=20
>>Takao Indoh <indou.takao@jp.fujitsu.com> wrote:
>>>As Intel manual says, it seems that pmsa_iip has a value of ip register
>>>where INIT interrupted when psr.ic is 0. Ok, I'll make a patch so that
>>>pmsa_iip is used irrespective of a value of psr.ic.
>>>
>>>Please let me know if I need to confirm something else before I make a
>>>patch.
>>
>>That looks good.  The only problem I can think of is an MCA/INIT
>>arriving while code like SAVE_MIN or SAVE_REST is executing.  Back
>>tracing at that point using pmsa_iip is going to be a problem, you have
>>no idea what state the registers or stack are in.
>
>I inserted another debug code into IA64_NATIVE_DO_SAVE_MIN to send
>INIT during SAVE_MIN.
>
>diff -Nurp a/arch/ia64/kernel/minstate.h b/arch/ia64/kernel/minstate.h
>--- a/arch/ia64/kernel/minstate.h   2009-10-22 12:28:07.000000000 -0400
>+++ b/arch/ia64/kernel/minstate.h   2009-10-27 12:42:02.000000000 -0400
>@@ -55,6 +55,14 @@
>    mov r21=3Dar.fpsr;        /* M */                         \
>    __COVER;                /* B;; (or nothing) */              \
>    ;;                                          \
>+   movl r24=DEbug_flag;    \
>+   ;;  \
>+   ld8 r23=3D[r24];  \
>+   ;;  \
>+   cmp.eq p2,p3=3D0,r23; \
>+(p2) br.sptk 2f;   \
>+1:   br.sptk 1b;   \
>+2: \
>    adds r16=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r16;                     \
>    ;;                                          \
>    ld1 r17=3D[r16];              /* load current->thread.on_ustack flag *=
/   \
>
>As a result, backtrace in the case using xip works, and backtrace in the
>case using iip does NOT work, as you said. Hm, it seems that I have to
>reconsider how to fix.

Now I think it's better to keep it as-is, I mean, use
pmsa_{xip,xpsr,xfs} if PSR.ic is 0. Instead of that, I'd like to
save pmsa_{iip,ipsr,ifs} somewhere for debugging. For example,

diff -Nurp a/arch/ia64/include/asm/mca.h b/arch/ia64/include/asm/mca.h
--- a/arch/ia64/include/asm/mca.h	2009-10-22 12:28:07.000000000 -0400
+++ b/arch/ia64/include/asm/mca.h	2009-11-03 17:01:33.000000000 -0500
@@ -106,6 +106,11 @@ struct ia64_sal_os_state {
 	unsigned long		os_status;		/* OS status to SAL, enum below */
 	unsigned long		context;		/* 0 if return to same context
 							   1 if return to new context */
+
+	/* I-resources */
+	unsigned long		iip;
+	unsigned long		ipsr;
+	unsigned long		ifs;
 };
=20
 enum {
diff -Nurp a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
--- a/arch/ia64/kernel/mca.c	2009-10-22 12:28:07.000000000 -0400
+++ b/arch/ia64/kernel/mca.c	2009-11-05 11:10:45.000000000 -0500
@@ -888,9 +888,10 @@ ia64_mca_modify_comm(const struct task_s
 }
=20
 static void
-finish_pt_regs(struct pt_regs *regs, const pal_min_state_area_t *ms,
+finish_pt_regs(struct pt_regs *regs, struct ia64_sal_os_state *sos,
 		unsigned long *nat)
 {
+	const pal_min_state_area_t *ms =3D sos->pal_min_state;
 	const u64 *bank;
=20
 	/* If ipsr.ic then use pmsa_{iip,ipsr,ifs}, else use
@@ -904,6 +905,10 @@ finish_pt_regs(struct pt_regs *regs, con
 		regs->cr_iip =3D ms->pmsa_xip;
 		regs->cr_ipsr =3D ms->pmsa_xpsr;
 		regs->cr_ifs =3D ms->pmsa_xfs;
+
+		sos->iip =3D ms->pmsa_iip;
+		sos->ipsr =3D ms->pmsa_ipsr;
+		sos->ifs =3D ms->pmsa_ifs;
 	}
 	regs->pr =3D ms->pmsa_pr;
 	regs->b0 =3D ms->pmsa_br0;
(snip)

Any idea or comments?

Thanks,
Takao Indoh
