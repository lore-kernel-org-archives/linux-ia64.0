From: Joe Perches <joe@perches.com>
Date: Wed, 25 May 2011 17:02:41 +0000
Subject: [PATCH 4/4] treewide: Remove asmlinkage from printk
Message-Id: <2053d1648f4f33f99ed8e096346e2133b2328951.1306342673.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BANLkTimo30L7feKr9_Ec=fMoe1erw8Rnag@mail.gmail.com>
In-Reply-To: <BANLkTimo30L7feKr9_Ec=fMoe1erw8Rnag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>, Xiantao Zhang <xiantao.zhang@intel.com>, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <randy.dunlap@oracle.com>, Russell King <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kvm-ia64@vger.kernel.org, kvm@vger.kernel.org, linux-ia64@vger.kernel.org

Remove the now unnecessary asmlinkage attribute from the various
printk prototypes and uses.

Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/arm/kernel/early_printk.c |    2 +-
 arch/ia64/kvm/vmm.c            |    2 +-
 arch/x86/kernel/early_printk.c |    2 +-
 include/linux/printk.h         |    6 +++---
 kernel/printk.c                |    6 +++---
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/arch/arm/kernel/early_printk.c b/arch/arm/kernel/early_printk.c
index 85aa2b2..46798d5 100644
--- a/arch/arm/kernel/early_printk.c
+++ b/arch/arm/kernel/early_printk.c
@@ -36,7 +36,7 @@ static struct console early_console = {
 	.index =	-1,
 };
 
-asmlinkage void early_printk(const char *fmt, ...)
+void early_printk(const char *fmt, ...)
 {
 	char buf[512];
 	int n;
diff --git a/arch/ia64/kvm/vmm.c b/arch/ia64/kvm/vmm.c
index f0b9cac..40331ac 100644
--- a/arch/ia64/kvm/vmm.c
+++ b/arch/ia64/kvm/vmm.c
@@ -81,7 +81,7 @@ static void vcpu_debug_exit(struct kvm_vcpu *vcpu)
 	local_irq_restore(psr);
 }
 
-asmlinkage int printk(const char *fmt, ...)
+int printk(const char *fmt, ...)
 {
 	struct kvm_vcpu *vcpu = current_vcpu;
 	va_list args;
diff --git a/arch/x86/kernel/early_printk.c b/arch/x86/kernel/early_printk.c
index cd28a35..b9b323a 100644
--- a/arch/x86/kernel/early_printk.c
+++ b/arch/x86/kernel/early_printk.c
@@ -173,7 +173,7 @@ static struct console early_serial_console = {
 static struct console *early_console = &early_vga_console;
 static int __initdata early_console_initialized;
 
-asmlinkage void early_printk(const char *fmt, ...)
+void early_printk(const char *fmt, ...)
 {
 	char buf[512];
 	int n;
diff --git a/include/linux/printk.h b/include/linux/printk.h
index 3736545..e52bc4b 100644
--- a/include/linux/printk.h
+++ b/include/linux/printk.h
@@ -90,16 +90,16 @@ int no_printk(const char *fmt, ...)
 	return 0;
 }
 
-extern asmlinkage __attribute__ ((format (printf, 1, 2)))
+extern __attribute__ ((format (printf, 1, 2)))
 void early_printk(const char *fmt, ...);
 
 extern int printk_needs_cpu(int cpu);
 extern void printk_tick(void);
 
 #ifdef CONFIG_PRINTK
-asmlinkage __attribute__ ((format (printf, 1, 0)))
+__attribute__ ((format (printf, 1, 0)))
 int vprintk(const char *fmt, va_list args);
-asmlinkage __attribute__ ((format (printf, 1, 2))) __cold
+__attribute__ ((format (printf, 1, 2))) __cold
 int printk(const char *fmt, ...);
 
 /*
diff --git a/kernel/printk.c b/kernel/printk.c
index da8ca81..735056c 100644
--- a/kernel/printk.c
+++ b/kernel/printk.c
@@ -46,7 +46,7 @@
 /*
  * Architectures can override it:
  */
-void asmlinkage __attribute__((weak)) early_printk(const char *fmt, ...)
+void __attribute__((weak)) early_printk(const char *fmt, ...)
 {
 }
 
@@ -704,7 +704,7 @@ static int have_callable_console(void)
  * See the vsnprintf() documentation for format string extensions over C99.
  */
 
-asmlinkage int printk(const char *fmt, ...)
+int printk(const char *fmt, ...)
 {
 	va_list args;
 	int r;
@@ -794,7 +794,7 @@ static inline void printk_delay(void)
 	}
 }
 
-asmlinkage int vprintk(const char *fmt, va_list args)
+int vprintk(const char *fmt, va_list args)
 {
 	int printed_len = 0;
 	int current_log_level = default_message_loglevel;
-- 
1.7.4.rc3

