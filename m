From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 17 Oct 2008 02:17:42 +0000
Subject: [PATCH 02/33] ia64/pv_ops: avoid name conflict of get_irq_chip().
Message-Id: <1224209893-2032-3-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The macro get_irq_chip() is defined in linux/include/linux/irq.h
which cause name conflict with one in linux/arch/ia64/include/asm/paravirt.h.
rename the latter to __get_irq_chip().

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/paravirt.h |    4 ++--
 arch/ia64/kernel/paravirt.c      |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/include/asm/paravirt.h b/arch/ia64/include/asm/paravirt.h
index 660cab0..2bf3636 100644
--- a/arch/ia64/include/asm/paravirt.h
+++ b/arch/ia64/include/asm/paravirt.h
@@ -117,7 +117,7 @@ static inline void paravirt_post_smp_prepare_boot_cpu(void)
 struct pv_iosapic_ops {
 	void (*pcat_compat_init)(void);
 
-	struct irq_chip *(*get_irq_chip)(unsigned long trigger);
+	struct irq_chip *(*__get_irq_chip)(unsigned long trigger);
 
 	unsigned int (*__read)(char __iomem *iosapic, unsigned int reg);
 	void (*__write)(char __iomem *iosapic, unsigned int reg, u32 val);
@@ -135,7 +135,7 @@ iosapic_pcat_compat_init(void)
 static inline struct irq_chip*
 iosapic_get_irq_chip(unsigned long trigger)
 {
-	return pv_iosapic_ops.get_irq_chip(trigger);
+	return pv_iosapic_ops.__get_irq_chip(trigger);
 }
 
 static inline unsigned int
diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
index afaf5b9..de35d8e 100644
--- a/arch/ia64/kernel/paravirt.c
+++ b/arch/ia64/kernel/paravirt.c
@@ -332,7 +332,7 @@ ia64_native_iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
 
 struct pv_iosapic_ops pv_iosapic_ops = {
 	.pcat_compat_init = ia64_native_iosapic_pcat_compat_init,
-	.get_irq_chip = ia64_native_iosapic_get_irq_chip,
+	.__get_irq_chip = ia64_native_iosapic_get_irq_chip,
 
 	.__read = ia64_native_iosapic_read,
 	.__write = ia64_native_iosapic_write,
-- 
1.6.0.2

