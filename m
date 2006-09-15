From: Horms <horms@verge.net.au>
Date: Fri, 15 Sep 2006 01:44:24 +0000
Subject: [PATCH] [IA64] kdump: kdump_disable_iosapic needs CONFIG_IOSAPIC
Message-Id: <20060915014422.GA21437@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Nanhai,

here is a minor patch against your lastest ia64 kexec patch.
kdump_disable_iosapic() doesn't exist without CONFIG_IOSAPIC,
calling it needs to be gaurded by a corresponding #ifdef

Signed-Off-By: Simon Horman <horms@verge.net.au>

diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
index aa63c47..e15e15d 100644
--- a/arch/ia64/kernel/crash.c
+++ b/arch/ia64/kernel/crash.c
@@ -42,7 +42,9 @@ size_t copy_oldmem_page(unsigned long pf
 
 static void device_shootdown(void)
 {
+#ifdef CONFIG_IOSAPIC
 	kdump_disable_iosapic();
+#endif
 #ifdef CONFIG_IA64_HP_ZX1
 	ioc_iova_disable();
 #endif
