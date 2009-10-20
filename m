From: Takao Indoh <indou.takao@jp.fujitsu.com>
Date: Tue, 20 Oct 2009 19:25:23 +0000
Subject: why ms->pmsa_xip is used?
Message-Id: <F6CA51BB11EE80indou.takao@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I have a question about how to restore cr_{iip,ipsr,ifs} register
in the INIT handler.

This is a part of ia64_mca_modify_original_stack().

        /* If ipsr.ic then use pmsa_{iip,ipsr,ifs}, else use
         * pmsa_{xip,xpsr,xfs}
         */
        if (ia64_psr(regs)->ic) {
                old_regs->cr_iip = ms->pmsa_iip;
                old_regs->cr_ipsr = ms->pmsa_ipsr;
                old_regs->cr_ifs = ms->pmsa_ifs;
        } else {
                old_regs->cr_iip = ms->pmsa_xip;
                old_regs->cr_ipsr = ms->pmsa_xpsr;
                old_regs->cr_ifs = ms->pmsa_xfs;
        }

Does anybody know why ms->pmsa_{xip,xpsr,xfs} are used instead of
ms->pmsa_{iip,ipsr,ifs} when PSR.ic is 0?

What we want to do here is to modify the original stack so it looks as
if it's interrupted by INIT, right? In my understainding, if PSR.ic is 0,
pmsa_iip has the value of IP register and pmsa_xip has the value of IIP
register. In other words, the value of pmsa_iip is where INIT handler
returns to, and the value of pmsa_xip is where interruption handler (not
INIT handler) returns to. So, to create pt_regs which has the state at
the time of interrupt by INIT, ms->pmsa_iip should be used when PSR.ic
is 0, I think. My understanding is correct?

Thanks,
Takao Indoh
