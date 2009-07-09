From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 09 Jul 2009 07:10:05 +0000
Subject: [PATCH v2 1/7] ia64, kdump: Mask MCA/INIT on frozen cpus
Message-Id: <4A5597CD.4060201@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4A39E247.4030908@jp.fujitsu.com> <4A5595F3.2050609@jp.fujitsu.com>
In-Reply-To: <4A5595F3.2050609@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Vivek Goyal <vgoyal@redhat.com>, Haren Myneni <hbabu@us.ibm.com>, kexec@lists.infradead.org, "Luck, Tony" <tony.luck@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>

Summary:

  INIT asserted on kdump kernel invokes INIT handler not only on a
  cpu that running on the kdump kernel, but also BSP of the panicked
  kernel, because the (badly) frozen BSP can be thawed by INIT.

Description:

  The kdump_cpu_freeze() is called on cpus except one that initiates
  panic and/or kdump, to stop/offline the cpu (on ia64, it means we
  pass control of cpus to SAL, or put them in spinloop).  Note that
  CPU0(BSP) always go to spinloop, so if panic was happened on an AP,
  there are at least 2cpus (=3D the AP and BSP) which not back to SAL.

  On the spinning cpus, interrupts are disabled (rsm psr.i), but INIT
  is still interruptible because psr.mc for mask them is not set unless
  kdump_cpu_freeze() is not called from MCA/INIT context.

  Therefore, assume that a panic was happened on an AP, kdump was
  invoked, new INIT handlers for kdump kernel was registered and then
  an INIT is asserted.  From the viewpoint of SAL, there are 2 online
  cpus, so INIT will be delivered to both of them.  It likely means
  that not only the AP (=3D a cpu executing kdump) enters INIT handler
  which is newly registered, but also BSP (=3D another cpu spinning in
  panicked kernel) enters the same INIT handler.  Of course setting of
  registers in BSP are still old (for panicked kernel), so what happen
  with running handler with wrong setting will be extremely unexpected.
  I believe this is not desirable behavior.

How to Reproduce:

  Start kdump on one of APs (e.g. cpu1)
    # taskset 0x2 echo c > /proc/sysrq-trigger
  Then assert INIT after kdump kernel is booted, after new INIT handler
  for kdump kernel is registered.

Expected results:

  An INIT handler is invoked only on the AP.

Actual results:

  An INIT handler is invoked on the AP and BSP.

Sample of results:

  I got following console log by asserting INIT after prompt "root:/>".
  It seems that two monarchs appeared by one INIT, and one panicked at
  last.  And it also seems that the panicked one supposed there were
  4 online cpus and no one did rendezvous:

    :
    [  0 %]dropping to initramfs shell
    exiting this shell will reboot your system
    root:/> Entered OS INIT handler. PSP=FFf301a0 cpu=3D0 monarch=3D0
    ia64_init_handler: Promoting cpu 0 to monarch.
    Delaying for 5 seconds...
    All OS INIT slaves have reached rendezvous
    Processes interrupted by INIT - 0 (cpu 0 task 0xa000000100af0000)
    :
    <<snip>>
    :
    Entered OS INIT handler. PSP=FFf301a0 cpu=3D0 monarch=3D1
    Delaying for 5 seconds...
    mlogbuf_finish: printing switched to urgent mode, MCA/INIT might be dod=
gy or fail.
    OS INIT slave did not rendezvous on cpu 1 2 3
    INIT swapper 0[0]: bugcheck! 0 [1]
    :
    <<snip>>
    :
    Kernel panic - not syncing: Attempted to kill the idle task!

Proposed fix:

  To avoid this problem, this patch inserts ia64_set_psr_mc() to mask
  INIT on cpus going to be frozen.  This masking have no effect if the
  kdump_cpu_freeze() is called from INIT handler when kdump_on_init =3D 1,
  because psr.mc is already turned on to 1 before entering OS_INIT.
  I confirmed that weird log like above are disappeared after applying
  this patch.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Vivek Goyal <vgoyal@redhat.com>
Cc: Haren Myneni <hbabu@us.ibm.com>
Cc: kexec@lists.infradead.org
---
 arch/ia64/include/asm/mca.h |    1 +
 arch/ia64/kernel/crash.c    |    4 ++++
 arch/ia64/kernel/head.S     |    2 +-
 arch/ia64/kernel/mca_asm.S  |   27 +++++++++++++++++++++++++++
 4 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/include/asm/mca.h b/arch/ia64/include/asm/mca.h
index 44a0b53..cb0952f 100644
--- a/arch/ia64/include/asm/mca.h
+++ b/arch/ia64/include/asm/mca.h
@@ -151,6 +151,7 @@ extern void ia64_mca_cmc_vector_setup(void);
 extern int  ia64_reg_MCA_extension(int (*fn)(void *, struct ia64_sal_os_st=
ate *));
 extern void ia64_unreg_MCA_extension(void);
 extern unsigned long ia64_get_rnat(unsigned long *);
+extern void ia64_set_psr_mc(void);
 extern void ia64_mca_printk(const char * fmt, ...)
 	 __attribute__ ((format (printf, 1, 2)));
=20
diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
index f065093..3f3a579 100644
--- a/arch/ia64/kernel/crash.c
+++ b/arch/ia64/kernel/crash.c
@@ -129,10 +129,14 @@ void
 kdump_cpu_freeze(struct unw_frame_info *info, void *arg)
 {
 	int cpuid;
+
 	local_irq_disable();
 	cpuid =3D smp_processor_id();
 	crash_save_this_cpu();
 	current->thread.ksp =3D (__u64)info->sw - 16;
+
+	ia64_set_psr_mc();	/* mask MCA/INIT and stop reentrance */
+
 	atomic_inc(&kdump_cpu_frozen);
 	kdump_status[cpuid] =3D 1;
 	mb();
diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index 23f846d..e1f97ac 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -1242,7 +1242,7 @@ GLOBAL_ENTRY(ia64_jump_to_sal)
 	movl r16=3DSAL_PSR_BITS_TO_SET;;
 	mov cr.ipsr=3Dr16
 	mov cr.ifs=3Dr0;;
-	rfi;;
+	rfi;;			// note: this unmask MCA/INIT (psr.mc)
 1:
 	/*
 	 * Invalidate all TLB data/inst
diff --git a/arch/ia64/kernel/mca_asm.S b/arch/ia64/kernel/mca_asm.S
index a06d465..8d2eabe 100644
--- a/arch/ia64/kernel/mca_asm.S
+++ b/arch/ia64/kernel/mca_asm.S
@@ -1073,3 +1073,30 @@ GLOBAL_ENTRY(ia64_get_rnat)
 	mov ar.rsc=3D3
 	br.ret.sptk.many rp
 END(ia64_get_rnat)
+
+
+// void ia64_set_psr_mc(void)
+//
+// Set psr.mc bit to mask MCA/INIT.
+GLOBAL_ENTRY(ia64_set_psr_mc)
+	rsm psr.i | psr.ic		// disable interrupts
+	;;
+	srlz.d
+	;;
+	mov r14 =3D psr			// get psr{36:35,31:0}
+	movl r15 =3D 1f
+	;;
+	dep r14 =3D -1, r14, PSR_MC, 1	// set psr.mc
+	;;
+	dep r14 =3D -1, r14, PSR_IC, 1	// set psr.ic
+	;;
+	dep r14 =3D -1, r14, PSR_BN, 1	// keep bank1 in use
+	;;
+	mov cr.ipsr =3D r14
+	mov cr.ifs =3D r0
+	mov cr.iip =3D r15
+	;;
+	rfi
+1:
+	br.ret.sptk.many rp
+END(ia64_set_psr_mc)
--=20
1.6.0


