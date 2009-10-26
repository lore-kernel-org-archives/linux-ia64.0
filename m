From: Takao Indoh <indou.takao@jp.fujitsu.com>
Date: Mon, 26 Oct 2009 22:15:22 +0000
Subject: Re: why ms->pmsa_xip is used?
Message-Id: <1CA5689CF5578indou.takao@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <F6CA51BB11EE80indou.takao@jp.fujitsu.com>
In-Reply-To: <F6CA51BB11EE80indou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 21 Oct 2009 10:53:18 +1100, Keith Owens wrote:

>On Tue, 20 Oct 2009 15:25:23 -0400, 
>Takao Indoh <indou.takao@jp.fujitsu.com> wrote:
>>Hi,
>>
>>I have a question about how to restore cr_{iip,ipsr,ifs} register
>>in the INIT handler.
>>
>>This is a part of ia64_mca_modify_original_stack().
>>
>>        /* If ipsr.ic then use pmsa_{iip,ipsr,ifs}, else use
>>         * pmsa_{xip,xpsr,xfs}
>>         */
>>        if (ia64_psr(regs)->ic) {
>>                old_regs->cr_iip = ms->pmsa_iip;
>>                old_regs->cr_ipsr = ms->pmsa_ipsr;
>>                old_regs->cr_ifs = ms->pmsa_ifs;
>>        } else {
>>                old_regs->cr_iip = ms->pmsa_xip;
>>                old_regs->cr_ipsr = ms->pmsa_xpsr;
>>                old_regs->cr_ifs = ms->pmsa_xfs;
>>        }
>>
>>Does anybody know why ms->pmsa_{xip,xpsr,xfs} are used instead of
>>ms->pmsa_{iip,ipsr,ifs} when PSR.ic is 0?
>
>That's my code.  Take a look at "OS Machine Check Recovery on
>Itanium Based Systems", http://download.intel.com/design/itanium/320482.pdf.
>Section 2.5, Min-State Save Area I-Resources and X-Resources.
>
>  On an interruption (either PAL-based or IVA-based), the processor
>  stores architectural state to the I-resources (IIP, IPSR, IIM, and
>  IFS). During interrupt handling, interrupt collection is masked with
>  PSR.ic = 0, but PSR.mc = 1 and machine check aborts can be delivered.
>
>  To permit error recovery when PSR.ic = 0, current Itanium processor
>  implementations provide optional X-resources (XIP, XPSR, XFS, XR0 -
>  XR4). (Availability of X-resources on a processor implementation can
>  be identified using PAL_PROC_GET_FEATURE bits 41 and 42.) If an MCA
>  occurs while PSR.ic = 0, the I-resources are saved to the X-resources
>  and the processor state at the time of the MCA is stored to the
>  I-resources.
>
>  The PAL MCA handler will copy I-resources and X-resources to the
>  min-state save area.  SAL_CHECK saves the min-state save area to
>  NVRAM in the processor error section and provides the error record to
>  OS_MCA when SAL_GET_STATE_INFO is called. OS_MCA can determine if an
>  interruption was in progress at the time of the MCA by examining
>  IPSR.ic. If IPSR.ic = 0, the X-resources provide information about
>  the processor state at the time the original interruption was taken.
>  If IPSR.ic = 1, the X-resources are undefined.
>
>>What we want to do here is to modify the original stack so it looks as
>>if it's interrupted by INIT, right? In my understainding, if PSR.ic is 0,
>>pmsa_iip has the value of IP register and pmsa_xip has the value of IIP
>>register. In other words, the value of pmsa_iip is where INIT handler
>>returns to, and the value of pmsa_xip is where interruption handler (not
>>INIT handler) returns to. So, to create pt_regs which has the state at
>>the time of interrupt by INIT, ms->pmsa_iip should be used when PSR.ic
>>is 0, I think. My understanding is correct?
>
>According to the extract above, ia64 MCA handler should always be using
>pmsa_iip, it is meant to be the IP at the time of the MCA.  I vaguely
>remember a test where I created an MCA with interrupts disabled and
>finding that I needed to use pmsa_xip, but that was a long time ago and
>I could be remembering it wrong.  I no longer have access to ia64
>equipment so I cannot test this.  If your tests show that pmsa_iip is
>valid when psr.ic = 0 then please change the code.

To confirm this, I inserted debug code like this:

diff -Nurp a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
--- a/arch/ia64/kernel/irq_ia64.c   2009-10-22 12:28:07.000000000 -0400
+++ b/arch/ia64/kernel/irq_ia64.c   2009-10-23 11:32:03.000000000 -0400
@@ -453,7 +453,12 @@ ia64_handle_irq (ia64_vector vector, str
 {
    struct pt_regs *old_regs = set_irq_regs(regs);
    unsigned long saved_tpr;
+   extern int debug;

+   if (debug) {
+       ia64_clear_ic();
+       while(1);
+   }
 #if IRQ_DEBUG
    {
        unsigned long bsp, sp;


After kernel hung, I sent INIT and took a vmcore by kdump to check a
value of pmsa_iip and pmsa_xip. Here is the result.

CPU0
    pmsa_iip = 0xa000000100013270 <ia64_handle_irq+144>
    pmsa_xip = 0xa000000100183800 <vfs_write+704>
CPU1
    pmsa_iip = 0xa000000100013270 <ia64_handle_irq+144>
    pmsa_xip = 0xa0000001006c3430 <_spin_unlock_irqrestore+48>
CPU2
    pmsa_iip = 0xa000000100013270 <ia64_handle_irq+144>
    pmsa_xip = 0xa00000010032ab20 <__copy_user+288>
CPU3
    pmsa_iip = 0xa000000100013270 <ia64_handle_irq+144>
    pmsa_xip = 0xa00000010010dff0 <find_get_page+208>
CPU4
    pmsa_iip = 0xa000000100013270 <ia64_handle_irq+144>
    pmsa_xip = 0x4000000000003180 <IN USER SPACE>
CPU5
    pmsa_iip = 0xa000000100013270 <ia64_handle_irq+144>
    pmsa_xip = 0xa000000000010720 <__kernel_syscall_via_break>
CPU6
    pmsa_iip = 0xa000000100013270 <ia64_handle_irq+144>
    pmsa_xip = 0xa00000010028e460 <cap_file_permission>
CPU7
    pmsa_iip = 0xa000000100013270 <ia64_handle_irq+144>
    pmsa_xip = 0xa000000100194ba0 <path_put>


As Intel manual says, it seems that pmsa_iip has a value of ip register
where INIT interrupted when psr.ic is 0. Ok, I'll make a patch so that
pmsa_iip is used irrespective of a value of psr.ic.

Please let me know if I need to confirm something else before I make a
patch.

Thanks,
Takao Indoh
