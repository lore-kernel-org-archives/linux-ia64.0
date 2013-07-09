From: Joe Perches <joe@perches.com>
Date: Tue, 09 Jul 2013 17:13:03 +0000
Subject: ia64: dmi.h: Make dmi_alloc use kzalloc
Message-Id: <1373389983.14604.18.camel@joe-AO722>
List-Id: <linux-ia64.vger.kernel.org>
References: <1373384438.4391.6.camel@chaos.site>
	 <1373384574.4391.9.camel@chaos.site> <1373386794.14604.14.camel@joe-AO722>
In-Reply-To: <1373386794.14604.14.camel@joe-AO722>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jean Delvare <jdelvare@suse.de>
Cc: linux-kernel@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>

x86/ia64 have a slight mismatch in dmi_alloc as
x86 does a memset(0), and ia64 just does kmalloc.

Make the ia64 dmi_alloc match the x86 style.

Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/ia64/include/asm/dmi.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/dmi.h b/arch/ia64/include/asm/dmi.h
index 1ed4c8f..185d3d1 100644
--- a/arch/ia64/include/asm/dmi.h
+++ b/arch/ia64/include/asm/dmi.h
@@ -7,6 +7,6 @@
 /* Use normal IO mappings for DMI */
 #define dmi_ioremap ioremap
 #define dmi_iounmap(x,l) iounmap(x)
-#define dmi_alloc(l) kmalloc(l, GFP_ATOMIC)
+#define dmi_alloc(l) kzalloc(l, GFP_ATOMIC)
 
 #endif


