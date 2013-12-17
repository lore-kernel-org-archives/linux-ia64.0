From: Mark Salter <msalter@redhat.com>
Date: Tue, 17 Dec 2013 15:48:53 +0000
Subject: [PATCH v2 10/10] Kconfig: cleanup SERIO_I8042 dependencies
Message-Id: <1387295333-24684-11-git-send-email-msalter@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1387295333-24684-1-git-send-email-msalter@redhat.com>
In-Reply-To: <1387295333-24684-1-git-send-email-msalter@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Remove messy dependencies from SERIO_I8042 by having it depend on one
Kconfig symbol (ARCH_MIGHT_HAVE_PC_SERIO) and having architectures
which need it select ARCH_MIGHT_HAVE_PC_SERIO in arch/*/Kconfig.
New architectures are unlikely to need SERIO_I8042, so this avoids
having an ever growing list of architectures to exclude.

Signed-off-by: Mark Salter <msalter@redhat.com>
Acked-by: "H. Peter Anvin" <hpa@zytor.com>
Acked-by: Ralf Baechle <ralf@linux-mips.org>
Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Dmitry Torokhov <dmitry.torokhov@gmail.com>
CC: Richard Henderson <rth@twiddle.net>
CC: linux-alpha@vger.kernel.org
CC: Russell King <linux@arm.linux.org.uk>
CC: linux-arm-kernel@lists.infradead.org
CC: Tony Luck <tony.luck@intel.com>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: linux-ia64@vger.kernel.org
CC: linux-mips@linux-mips.org
CC: Paul Mackerras <paulus@samba.org>
CC: linuxppc-dev@lists.ozlabs.org
CC: Paul Mundt <lethal@linux-sh.org>
CC: linux-sh@vger.kernel.org
CC: "David S. Miller" <davem@davemloft.net>
CC: sparclinux@vger.kernel.org
CC: Guan Xuetao <gxt@mprc.pku.edu.cn>
CC: Ingo Molnar <mingo@redhat.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: x86@kernel.org
---
 drivers/input/serio/Kconfig | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/input/serio/Kconfig b/drivers/input/serio/Kconfig
index 8541f94..1f5cec2 100644
--- a/drivers/input/serio/Kconfig
+++ b/drivers/input/serio/Kconfig
@@ -16,14 +16,19 @@ config SERIO
 	  To compile this driver as a module, choose M here: the
 	  module will be called serio.
 
+config ARCH_MIGHT_HAVE_PC_SERIO
+	bool
+	help
+	  Select this config option from the architecture Kconfig if
+	  the architecture might use a PC serio device (i8042) to
+          communicate with keyboard, mouse, etc.
+
 if SERIO
 
 config SERIO_I8042
 	tristate "i8042 PC Keyboard controller"
 	default y
-	depends on !PARISC && (!ARM || FOOTBRIDGE_HOST) && \
-		   (!SUPERH || SH_CAYMAN) && !M68K && !BLACKFIN && !S390 && \
-		   !ARC
+	depends on ARCH_MIGHT_HAVE_PC_SERIO
 	help
 	  i8042 is the chip over which the standard AT keyboard and PS/2
 	  mouse are connected to the computer. If you use these devices,
-- 
1.8.3.1

