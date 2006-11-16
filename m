From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 16 Nov 2006 19:30:47 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200611161930.kAGJUlI5025620@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release
[or
	master.kernel.org:/pub/scm/linux/kernel/git/aegl/linux-2.6.git release
as I hear that git.kernel.org is being cranky today]

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/hp/sim/Kconfig      |    4 ++--
 arch/ia64/hp/sim/hpsim_irq.c  |    2 +-
 arch/ia64/kernel/iosapic.c    |    6 +++---
 arch/ia64/kernel/irq.c        |    4 ++--
 arch/ia64/kernel/irq_ia64.c   |    4 ++--
 arch/ia64/kernel/irq_lsapic.c |    2 +-
 arch/ia64/sn/kernel/bte.c     |    9 ++++-----
 arch/ia64/sn/kernel/irq.c     |    2 +-
 8 files changed, 16 insertions(+), 17 deletions(-)

Andrew Morton:
      [IA64] irqs: use `name' not `typename'

Ingo Molnar:
      [IA64] typename -> name conversion
      [IA64] use generic_handle_irq()

Robin Holt:
      [IA64] bte_unaligned_copy() transfers one extra cache line.

Tony Luck:
      [IA64] a fix towards allmodconfig build

--- git whatchanged -p output follows ---

commit cea196bb2eb918c30f97a2b752bcec929d761f64
Author: Luck, Tony <tony.luck@intel.com>
Date:   Thu Nov 16 00:43:12 2006 -0800

    [IA64] a fix towards allmodconfig build
   =20
    The HP_SIMSCSI driver can't be built as a module (unhealthy dependencie=
s on
    things that shouldn't really be exported).
   =20
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/hp/sim/Kconfig b/arch/ia64/hp/sim/Kconfig
index 18ccb12..f92306b 100644
--- a/arch/ia64/hp/sim/Kconfig
+++ b/arch/ia64/hp/sim/Kconfig
@@ -13,8 +13,8 @@ config HP_SIMSERIAL_CONSOLE
 	depends on HP_SIMSERIAL
=20
 config HP_SIMSCSI
-	tristate "Simulated SCSI disk"
-	depends on SCSI
+	bool "Simulated SCSI disk"
+	depends on SCSI=3Dy
=20
 endmenu
=20

commit 5fbb004aba15bbca64c3fb611113295bda7ee9ea
Author: Ingo Molnar <mingo@elte.hu>
Date:   Thu Nov 16 00:43:07 2006 -0800

    [IA64] use generic_handle_irq()
   =20
    Use generic_handle_irq() to handle mixed-type irq handling.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
index 6fe404d..54d55e4 100644
--- a/arch/ia64/kernel/irq.c
+++ b/arch/ia64/kernel/irq.c
@@ -197,7 +197,7 @@ void fixup_irqs(void)
 			struct pt_regs *old_regs =3D set_irq_regs(NULL);
=20
 			vectors_in_migration[irq]=3D0;
-			__do_IRQ(irq);
+			generic_handle_irq(irq);
 			set_irq_regs(old_regs);
 		}
 	}
diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 9c6dafa..ba3ba8b 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -186,7 +186,7 @@ #endif /* IRQ_DEBUG */
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
 			ia64_srlz_d();
=20
-			__do_IRQ(local_vector_to_irq(vector));
+			generic_handle_irq(local_vector_to_irq(vector));
=20
 			/*
 			 * Disable interrupts and send EOI:
@@ -242,7 +242,7 @@ void ia64_process_pending_intr(void)
 			 * Probably could shared code.
 			 */
 			vectors_in_migration[local_vector_to_irq(vector)]=3D0;
-			__do_IRQ(local_vector_to_irq(vector));
+			generic_handle_irq(local_vector_to_irq(vector));
 			set_irq_regs(old_regs);
=20
 			/*

commit 06344db3162323247e9ac8d76d5acdb79d05f3c0
Author: Ingo Molnar <mingo@elte.hu>
Date:   Thu Nov 16 00:43:02 2006 -0800

    [IA64] typename -> name conversion
   =20
    convert irq chip typename -> name.
   =20
    Signed-off-by: Ingo Molnar <mingo@elte.hu>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/hp/sim/hpsim_irq.c b/arch/ia64/hp/sim/hpsim_irq.c
index 8145547..c2f58ff 100644
--- a/arch/ia64/hp/sim/hpsim_irq.c
+++ b/arch/ia64/hp/sim/hpsim_irq.c
@@ -27,7 +27,7 @@ hpsim_set_affinity_noop (unsigned int a,
 }
=20
 static struct hw_interrupt_type irq_type_hp_sim =3D {
-	.typename =3D	"hpsim",
+	.name =3D		"hpsim",
 	.startup =3D	hpsim_irq_startup,
 	.shutdown =3D	hpsim_irq_noop,
 	.enable =3D	hpsim_irq_noop,
diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index c195faf..60d6495 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -426,7 +426,7 @@ #define iosapic_disable_level_irq	mask_i
 #define iosapic_ack_level_irq		nop
=20
 struct hw_interrupt_type irq_type_iosapic_level =3D {
-	.typename =3D	"IO-SAPIC-level",
+	.name =3D		"IO-SAPIC-level",
 	.startup =3D	iosapic_startup_level_irq,
 	.shutdown =3D	iosapic_shutdown_level_irq,
 	.enable =3D	iosapic_enable_level_irq,
@@ -473,7 +473,7 @@ #define iosapic_disable_edge_irq	nop
 #define iosapic_end_edge_irq		nop
=20
 struct hw_interrupt_type irq_type_iosapic_edge =3D {
-	.typename =3D	"IO-SAPIC-edge",
+	.name =3D		"IO-SAPIC-edge",
 	.startup =3D	iosapic_startup_edge_irq,
 	.shutdown =3D	iosapic_disable_edge_irq,
 	.enable =3D	iosapic_enable_edge_irq,
diff --git a/arch/ia64/kernel/irq_lsapic.c b/arch/ia64/kernel/irq_lsapic.c
index 1ab58b0..c2f07be 100644
--- a/arch/ia64/kernel/irq_lsapic.c
+++ b/arch/ia64/kernel/irq_lsapic.c
@@ -34,7 +34,7 @@ static int lsapic_retrigger(unsigned int
 }
=20
 struct hw_interrupt_type irq_type_ia64_lsapic =3D {
-	.typename =3D	"LSAPIC",
+	.name =3D		"LSAPIC",
 	.startup =3D	lsapic_noop_startup,
 	.shutdown =3D	lsapic_noop,
 	.enable =3D	lsapic_noop,
diff --git a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
index 7bb6ad1..0b49459 100644
--- a/arch/ia64/sn/kernel/irq.c
+++ b/arch/ia64/sn/kernel/irq.c
@@ -201,7 +201,7 @@ static void sn_set_affinity_irq(unsigned
 }
=20
 struct hw_interrupt_type irq_type_sn =3D {
-	.typename	=3D "SN hub",
+	.name		=3D "SN hub",
 	.startup	=3D sn_startup_irq,
 	.shutdown	=3D sn_shutdown_irq,
 	.enable		=3D sn_enable_irq,

commit 351a58390aad350bd5e22c7cc468f44a9330685c
Author: Andrew Morton <akpm@osdl.org>
Date:   Thu Nov 16 00:42:58 2006 -0800

    [IA64] irqs: use `name' not `typename'
   =20
    `typename' is going away and is usually uninitialised anwyay.
   =20
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index 9bf15fe..c195faf 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -664,7 +664,7 @@ register_intr (unsigned int gsi, int vec
 			printk(KERN_WARNING
 			       "%s: changing vector %d from %s to %s\n",
 			       __FUNCTION__, vector,
-			       idesc->chip->typename, irq_type->typename);
+			       idesc->chip->name, irq_type->name);
 		idesc->chip =3D irq_type;
 	}
 	return 0;
diff --git a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
index f07c086..6fe404d 100644
--- a/arch/ia64/kernel/irq.c
+++ b/arch/ia64/kernel/irq.c
@@ -76,7 +76,7 @@ #else
 			seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
 		}
 #endif
-		seq_printf(p, " %14s", irq_desc[i].chip->typename);
+		seq_printf(p, " %14s", irq_desc[i].chip->name);
 		seq_printf(p, "  %s", action->name);
=20
 		for (action=ACtion->next; action; action =3D action->next)

commit cbf093e8c7447a202e376199cc017161262bd7cd
Author: Robin Holt <holt@sgi.com>
Date:   Tue Nov 14 20:50:59 2006 -0600

    [IA64] bte_unaligned_copy() transfers one extra cache line.
   =20
    When called to do a transfer that has a start offset within the cache
    line which is uneven between source and destination and a length which
    terminates the source of the copy exactly on a cache line, one extra
    line gets copied into a temporary buffer.  This is normally not an issue
    since the buffer is a kernel buffer and only the requested information
    gets copied into the user buffer.
   =20
    The problem arises when the source ends at the very last physical page
    of memory.  That last cache line does not exist and results in the SHUB
    chip raising an MCA.
   =20
    Signed-off-by: Robin Holt <holt@sgi.com>
    Signed-off-by: Dean Nelson <dcn@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/bte.c b/arch/ia64/sn/kernel/bte.c
index 7f73ad4..ff1c556 100644
--- a/arch/ia64/sn/kernel/bte.c
+++ b/arch/ia64/sn/kernel/bte.c
@@ -381,14 +381,13 @@ bte_result_t bte_unaligned_copy(u64 src,
 		 * bcopy to the destination.
 		 */
=20
-		/* Add the leader from source */
-		headBteLen =3D len + (src & L1_CACHE_MASK);
-		/* Add the trailing bytes from footer. */
-		headBteLen +=3D L1_CACHE_BYTES - (headBteLen & L1_CACHE_MASK);
-		headBteSource =3D src & ~L1_CACHE_MASK;
 		headBcopySrcOffset =3D src & L1_CACHE_MASK;
 		headBcopyDest =3D dest;
 		headBcopyLen =3D len;
+
+		headBteSource =3D src - headBcopySrcOffset;
+		/* Add the leading and trailing bytes from source */
+		headBteLen =3D L1_CACHE_ALIGN(len + headBcopySrcOffset);
 	}
=20
 	if (headBcopyLen > 0) {
