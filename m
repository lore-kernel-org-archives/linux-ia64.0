From: Paul Bolle <pebolle@tiscali.nl>
Date: Mon, 08 Apr 2013 21:01:42 +0000
Subject: [PATCH] arch/ia64/xen: remove "config NO_IDLE_HZ"
Message-Id: <1365454902.1830.138.camel@x61.thuisdomein>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The Kconfig symbol NO_IDLE_HZ, and its last users, were removed in
v2.6.27. It popped up again, for some reason, in the Kconfig file for
Xen on ia64 in v2.6.28. Remove it from that file now.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
 arch/ia64/xen/Kconfig | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/arch/ia64/xen/Kconfig b/arch/ia64/xen/Kconfig
index 5d8a06b..592999e 100644
--- a/arch/ia64/xen/Kconfig
+++ b/arch/ia64/xen/Kconfig
@@ -7,7 +7,6 @@ config XEN
 	default y
 	depends on PARAVIRT && MCKINLEY && IA64_PAGE_SIZE_16KB
 	select XEN_XENCOMM
-	select NO_IDLE_HZ
 	# followings are required to save/restore.
 	select ARCH_SUSPEND_POSSIBLE
 	select SUSPEND
@@ -19,7 +18,3 @@ config XEN
 config XEN_XENCOMM
 	depends on XEN
 	bool
-
-config NO_IDLE_HZ
-	depends on XEN
-	bool
-- 
1.7.11.7

