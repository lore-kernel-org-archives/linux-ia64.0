From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 09 Jul 2009 07:15:53 +0000
Subject: [PATCH v2 5/7] ia64, kdump: Mask INIT first in panic-kdump path
Message-Id: <4A559929.6040600@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4A39E247.4030908@jp.fujitsu.com> <4A5595F3.2050609@jp.fujitsu.com>
In-Reply-To: <4A5595F3.2050609@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Vivek Goyal <vgoyal@redhat.com>, Haren Myneni <hbabu@us.ibm.com>, kexec@lists.infradead.org, "Luck, Tony" <tony.luck@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>

Summary:

  Asserting INIT might block kdump if the system is already going to
  start kdump via panic.

Description:

  INIT can interrupt anywhere in panic path, so it can interrupt in
  middle of kdump kicked by panic.  Therefore there is a race if kdump
  is kicked concurrently, via Panic and via INIT.

  INIT could fail to invoke kdump if the system is already going to
  start kdump via panic.  It could not restart kdump from INIT handler
  if some of cpus are already playing dead with INIT masked.  It also
  means that INIT could block kdump's progress if no monarch is entered
  in the INIT rendezvous.

  Panic+INIT is a rare, but possible situation since it can be assumed
  that the kernel or an internal agent decides to panic the unstable
  system while another external agent decides to send an INIT to the
  system at same time.

How to reproduce:

  Assert INIT just after panic, before all other cpus have frozen

Expected results:

  continue kdump invoked by panic, or restart kdump from INIT

Actual results:

  might be hang, crashdump not retrieved

Proposed Fix:

  This patch masks INIT first in panic path to take the initiative on
  kdump, and reuse atomic value kdump_in_progress to make sure there is
  only one initiator of kdump.  All INITs asserted later should be used
  only for freezing all other cpus.

  This mask will be removed soon by rfi in relocate_kernel.S, before jump
  into kdump kernel, after all cpus are frozen and no-op INIT handler is
  registered.  So if INIT was in the interval while it is masked, it will
  pend on the system and will received just after the rfi, and handled by
  the no-op handler.

  If there was a MCA event while psr.mc is 1, in theory the event will
  pend on the system and will received just after the rfi same as above.
  MCA handler is unregistered here at the time, so received MCA will not
  reach to OS_MCA and will result in warmboot by SAL.

  Note that codes in this masked interval are relatively simpler than
  that in MCA/INIT handler which also executed with the mask.  So it can
  be said that probability of error in this interval is supposed not so
  higher than that in MCA/INIT handler.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Vivek Goyal <vgoyal@redhat.com>
Cc: Haren Myneni <hbabu@us.ibm.com>
Cc: kexec@lists.infradead.org
---
 arch/ia64/kernel/crash.c           |   47 +++++++++++++++++++++++++++++++----
 arch/ia64/kernel/relocate_kernel.S |    2 +-
 2 files changed, 42 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
index b2a8b3d..9c851b7 100644
--- a/arch/ia64/kernel/crash.c
+++ b/arch/ia64/kernel/crash.c
@@ -23,6 +23,7 @@
 int kdump_status[NR_CPUS];
 static atomic_t kdump_cpu_frozen;
 atomic_t kdump_in_progress;
+static int kdump_freeze_monarch;
 static int kdump_on_init = 1;
 static int kdump_on_fatal_mca = 1;
 
@@ -108,6 +109,33 @@ machine_crash_shutdown(struct pt_regs *pt)
 	 */
 	kexec_disable_iosapic();
 #ifdef CONFIG_SMP
+	/*
+	 * If kdump_on_init is set and an INIT is asserted here, kdump will
+	 * be started again via INIT monarch.
+	 */
+	local_irq_disable();
+	ia64_set_psr_mc();	/* mask MCA/INIT */
+	if (atomic_inc_return(&kdump_in_progress) != 1)
+		unw_init_running(kdump_cpu_freeze, NULL);
+
+	/*
+	 * Now this cpu is ready for kdump.
+	 * Stop all others by IPI or INIT.  They could receive INIT from
+	 * outside and might be INIT monarch, but only thing they have to
+	 * do is falling into kdump_cpu_freeze().
+	 *
+	 * If an INIT is asserted here:
+	 * - All receivers might be slaves, since some of cpus could already
+	 *   be frozen and INIT might be masked on monarch.  In this case,
+	 *   all slaves will park in while (monarch_cpu = -1) loop before
+	 *   DIE_INIT_SLAVE_ENTER that for waiting monarch enters.
+	 *	=> TBD: freeze all slaves
+	 * - One might be a monarch, but INIT rendezvous will fail since
+	 *   at least this cpu already have INIT masked so it never join
+	 *   to the rendezvous.  In this case, all slaves and monarch will
+	 *   be frozen after timeout of the INIT rendezvous.
+	 *	=> TBD: freeze them without waiting timeout
+	 */
 	kdump_smp_send_stop();
 	/* not all cpu response to IPI, send INIT to freeze them */
 	if (kdump_wait_cpu_freeze() && kdump_on_init) 	{
@@ -177,13 +205,18 @@ kdump_init_notifier(struct notifier_block *self, unsigned long val, void *data)
 	switch (val) {
 	case DIE_INIT_MONARCH_PROCESS:
 		if (kdump_on_init) {
-			atomic_set(&kdump_in_progress, 1);
+			if (atomic_inc_return(&kdump_in_progress) != 1)
+				kdump_freeze_monarch = 1;
 			*(nd->monarch_cpu) = -1;
 		}
 		break;
 	case DIE_INIT_MONARCH_LEAVE:
-		if (kdump_on_init)
-			machine_kdump_on_init();
+		if (kdump_on_init) {
+			if (kdump_freeze_monarch)
+				unw_init_running(kdump_cpu_freeze, NULL);
+			else
+				machine_kdump_on_init();
+		}
 		break;
 	case DIE_INIT_SLAVE_LEAVE:
 		if (atomic_read(&kdump_in_progress))
@@ -196,9 +229,11 @@ kdump_init_notifier(struct notifier_block *self, unsigned long val, void *data)
 	case DIE_MCA_MONARCH_LEAVE:
 		/* *(nd->data) indicate if MCA is recoverable */
 		if (kdump_on_fatal_mca && !(*(nd->data))) {
-			atomic_set(&kdump_in_progress, 1);
-			*(nd->monarch_cpu) = -1;
-			machine_kdump_on_init();
+			if (atomic_inc_return(&kdump_in_progress) = 1) {
+				*(nd->monarch_cpu) = -1;
+				machine_kdump_on_init();
+			}
+			/* We got fatal MCA while kdump!? No way!! */
 		}
 		break;
 	}
diff --git a/arch/ia64/kernel/relocate_kernel.S b/arch/ia64/kernel/relocate_kernel.S
index 903babd..32f6fc1 100644
--- a/arch/ia64/kernel/relocate_kernel.S
+++ b/arch/ia64/kernel/relocate_kernel.S
@@ -52,7 +52,7 @@ GLOBAL_ENTRY(relocate_new_kernel)
 	srlz.i
 	;;
 	mov ar.rnat=r18
-	rfi
+	rfi				// note: this unmask MCA/INIT (psr.mc)
 	;;
 1:
 	//physical mode code begin
-- 
1.6.0


