From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Date: Mon, 09 Dec 2013 05:21:27 +0000
Subject: [PATCH][RESEND] ia64/xen: remove unused NO_IDLE_HZ Kconfig parameter
Message-Id: <1386566487-19623-1-git-send-email-michael.opdenacker@free-electrons.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1383559638-5739-1-git-send-email-michael.opdenacker@free-electrons.com>
In-Reply-To: <1383559638-5739-1-git-send-email-michael.opdenacker@free-electrons.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Michael Opdenacker <michael.opdenacker@free-electrons.com>

This removes the NO_IDLE_HZ Kconfig parameter,
which was no longer used anywhere in the source code
and Makefiles.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 arch/ia64/xen/Kconfig | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/arch/ia64/xen/Kconfig b/arch/ia64/xen/Kconfig
index 5d8a06b0ddf7..592999efc419 100644
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
1.8.3.2

