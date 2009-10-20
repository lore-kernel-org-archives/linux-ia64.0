From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 20 Oct 2009 23:53:18 +0000
Subject: Re: why ms->pmsa_xip is used?
Message-Id: <14290.1256082798@ocs14w>
List-Id: <linux-ia64.vger.kernel.org>
References: <F6CA51BB11EE80indou.takao@jp.fujitsu.com>
In-Reply-To: <F6CA51BB11EE80indou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, 20 Oct 2009 15:25:23 -0400,=20
Takao Indoh <indou.takao@jp.fujitsu.com> wrote:
>Hi,
>
>I have a question about how to restore cr_{iip,ipsr,ifs} register
>in the INIT handler.
>
>This is a part of ia64_mca_modify_original_stack().
>
>        /* If ipsr.ic then use pmsa_{iip,ipsr,ifs}, else use
>         * pmsa_{xip,xpsr,xfs}
>         */
>        if (ia64_psr(regs)->ic) {
>                old_regs->cr_iip =3D ms->pmsa_iip;
>                old_regs->cr_ipsr =3D ms->pmsa_ipsr;
>                old_regs->cr_ifs =3D ms->pmsa_ifs;
>        } else {
>                old_regs->cr_iip =3D ms->pmsa_xip;
>                old_regs->cr_ipsr =3D ms->pmsa_xpsr;
>                old_regs->cr_ifs =3D ms->pmsa_xfs;
>        }
>
>Does anybody know why ms->pmsa_{xip,xpsr,xfs} are used instead of
>ms->pmsa_{iip,ipsr,ifs} when PSR.ic is 0?

That's my code.  Take a look at "OS Machine Check Recovery on
Itanium Based Systems", http://download.intel.com/design/itanium/320482.pdf.
Section 2.5, Min-State Save Area I-Resources and X-Resources.

  On an interruption (either PAL-based or IVA-based), the processor
  stores architectural state to the I-resources (IIP, IPSR, IIM, and
  IFS). During interrupt handling, interrupt collection is masked with
  PSR.ic =3D 0, but PSR.mc =3D 1 and machine check aborts can be delivered.

  To permit error recovery when PSR.ic =3D 0, current Itanium processor
  implementations provide optional X-resources (XIP, XPSR, XFS, XR0 =C2=AD
  XR4). (Availability of X-resources on a processor implementation can
  be identified using PAL_PROC_GET_FEATURE bits 41 and 42.) If an MCA
  occurs while PSR.ic =3D 0, the I-resources are saved to the X-resources
  and the processor state at the time of the MCA is stored to the
  I-resources.

  The PAL MCA handler will copy I-resources and X-resources to the
  min-state save area.  SAL_CHECK saves the min-state save area to
  NVRAM in the processor error section and provides the error record to
  OS_MCA when SAL_GET_STATE_INFO is called. OS_MCA can determine if an
  interruption was in progress at the time of the MCA by examining
  IPSR.ic. If IPSR.ic =3D 0, the X-resources provide information about
  the processor state at the time the original interruption was taken.
  If IPSR.ic =3D 1, the X-resources are undefined.

>What we want to do here is to modify the original stack so it looks as
>if it's interrupted by INIT, right? In my understainding, if PSR.ic is 0,
>pmsa_iip has the value of IP register and pmsa_xip has the value of IIP
>register. In other words, the value of pmsa_iip is where INIT handler
>returns to, and the value of pmsa_xip is where interruption handler (not
>INIT handler) returns to. So, to create pt_regs which has the state at
>the time of interrupt by INIT, ms->pmsa_iip should be used when PSR.ic
>is 0, I think. My understanding is correct?

According to the extract above, ia64 MCA handler should always be using
pmsa_iip, it is meant to be the IP at the time of the MCA.  I vaguely
remember a test where I created an MCA with interrupts disabled and
finding that I needed to use pmsa_xip, but that was a long time ago and
I could be remembering it wrong.  I no longer have access to ia64
equipment so I cannot test this.  If your tests show that pmsa_iip is
valid when psr.ic =3D 0 then please change the code.

