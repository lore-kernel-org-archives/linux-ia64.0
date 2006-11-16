From: akpm@osdl.org
Date: Thu, 16 Nov 2006 08:43:02 +0000
Subject: [patch 2/4] ia64: typename -> name conversion
Message-Id: <200611160843.kAG8h3mS017743@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>

convert irq chip typename -> name.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 arch/ia64/hp/sim/hpsim_irq.c  |    2 +-
 arch/ia64/kernel/iosapic.c    |    4 ++--
 arch/ia64/kernel/irq_lsapic.c |    2 +-
 arch/ia64/sn/kernel/irq.c     |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff -puN arch/ia64/hp/sim/hpsim_irq.c~ia64-typename-name-conversion arch/ia64/hp/sim/hpsim_irq.c
--- a/arch/ia64/hp/sim/hpsim_irq.c~ia64-typename-name-conversion
+++ a/arch/ia64/hp/sim/hpsim_irq.c
@@ -27,7 +27,7 @@ hpsim_set_affinity_noop (unsigned int a,
 }
 
 static struct hw_interrupt_type irq_type_hp_sim = {
-	.typename =	"hpsim",
+	.name =		"hpsim",
 	.startup =	hpsim_irq_startup,
 	.shutdown =	hpsim_irq_noop,
 	.enable =	hpsim_irq_noop,
diff -puN arch/ia64/kernel/iosapic.c~ia64-typename-name-conversion arch/ia64/kernel/iosapic.c
--- a/arch/ia64/kernel/iosapic.c~ia64-typename-name-conversion
+++ a/arch/ia64/kernel/iosapic.c
@@ -448,7 +448,7 @@ iosapic_end_level_irq (unsigned int irq)
 #define iosapic_ack_level_irq		nop
 
 struct hw_interrupt_type irq_type_iosapic_level = {
-	.typename =	"IO-SAPIC-level",
+	.name =		"IO-SAPIC-level",
 	.startup =	iosapic_startup_level_irq,
 	.shutdown =	iosapic_shutdown_level_irq,
 	.enable =	iosapic_enable_level_irq,
@@ -495,7 +495,7 @@ iosapic_ack_edge_irq (unsigned int irq)
 #define iosapic_end_edge_irq		nop
 
 struct hw_interrupt_type irq_type_iosapic_edge = {
-	.typename =	"IO-SAPIC-edge",
+	.name =		"IO-SAPIC-edge",
 	.startup =	iosapic_startup_edge_irq,
 	.shutdown =	iosapic_disable_edge_irq,
 	.enable =	iosapic_enable_edge_irq,
diff -puN arch/ia64/kernel/irq_lsapic.c~ia64-typename-name-conversion arch/ia64/kernel/irq_lsapic.c
--- a/arch/ia64/kernel/irq_lsapic.c~ia64-typename-name-conversion
+++ a/arch/ia64/kernel/irq_lsapic.c
@@ -34,7 +34,7 @@ static int lsapic_retrigger(unsigned int
 }
 
 struct hw_interrupt_type irq_type_ia64_lsapic = {
-	.typename =	"LSAPIC",
+	.name =		"LSAPIC",
 	.startup =	lsapic_noop_startup,
 	.shutdown =	lsapic_noop,
 	.enable =	lsapic_noop,
diff -puN arch/ia64/sn/kernel/irq.c~ia64-typename-name-conversion arch/ia64/sn/kernel/irq.c
--- a/arch/ia64/sn/kernel/irq.c~ia64-typename-name-conversion
+++ a/arch/ia64/sn/kernel/irq.c
@@ -201,7 +201,7 @@ static void sn_set_affinity_irq(unsigned
 }
 
 struct hw_interrupt_type irq_type_sn = {
-	.typename	= "SN hub",
+	.name		= "SN hub",
 	.startup	= sn_startup_irq,
 	.shutdown	= sn_shutdown_irq,
 	.enable		= sn_enable_irq,
_
