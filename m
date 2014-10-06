From: Thierry Reding <thierry.reding@gmail.com>
Date: Mon, 06 Oct 2014 13:52:34 +0000
Subject: [PATCH 2/9] ARM: ebsa110: Properly override I/O accessors
Message-Id: <1412603561-27653-3-git-send-email-thierry.reding@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412603561-27653-1-git-send-email-thierry.reding@gmail.com>
In-Reply-To: <1412603561-27653-1-git-send-email-thierry.reding@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Olof Johansson <olof@lixom.net>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Boyd <sboyd@codeaurora.org>, Sam Ravnborg <sam@ravnborg.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, linux-serial@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

In order to override accessors properly they must be #define'd so that
subsequent generic headers (the one for ARM and finally the architecture
independent one) can properly detect it.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 arch/arm/mach-ebsa110/include/mach/io.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/arm/mach-ebsa110/include/mach/io.h b/arch/arm/mach-ebsa110/include/mach/io.h
index 11bb0799424b..c15c1a89cb13 100644
--- a/arch/arm/mach-ebsa110/include/mach/io.h
+++ b/arch/arm/mach-ebsa110/include/mach/io.h
@@ -62,20 +62,31 @@ void __writel(u32 val, void __iomem *addr);
 #define writew(v,b)		__writew(v,b)
 #define writel(v,b)		__writel(v,b)
 
+#define insb insb
 extern void insb(unsigned int port, void *buf, int sz);
+#define insw insw
 extern void insw(unsigned int port, void *buf, int sz);
+#define insl insl
 extern void insl(unsigned int port, void *buf, int sz);
 
+#define outsb outsb
 extern void outsb(unsigned int port, const void *buf, int sz);
+#define outsw outsw
 extern void outsw(unsigned int port, const void *buf, int sz);
+#define outsl outsl
 extern void outsl(unsigned int port, const void *buf, int sz);
 
 /* can't support writesb atm */
+#define writesw writesw
 extern void writesw(void __iomem *addr, const void *data, int wordlen);
+#define writesl writesl
 extern void writesl(void __iomem *addr, const void *data, int longlen);
 
 /* can't support readsb atm */
+#define readsw readsw
 extern void readsw(const void __iomem *addr, void *data, int wordlen);
+
+#define readsl readsl
 extern void readsl(const void __iomem *addr, void *data, int longlen);
 
 #endif
-- 
2.1.0

