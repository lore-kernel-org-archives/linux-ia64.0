From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:07:42 +0000
Subject: [PATCH 05/11] xen: move features.c from arch/x86/xen/features.c to drivers/xen.
Message-Id: <12036568693679-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12036568683779-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12036568683779-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, yamahata@valinux.co.jp

ia64/xen also uses it too, so move it into common place.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/x86/xen/Makefile                |    2 +-
 drivers/xen/Makefile                 |    2 +-
 {arch/x86 => drivers}/xen/features.c |    0 
 3 files changed, 2 insertions(+), 2 deletions(-)
 rename {arch/x86 => drivers}/xen/features.c (100%)

diff --git a/arch/x86/xen/Makefile b/arch/x86/xen/Makefile
index 343df24..c5e9aa4 100644
--- a/arch/x86/xen/Makefile
+++ b/arch/x86/xen/Makefile
@@ -1,4 +1,4 @@
-obj-y		:= enlighten.o setup.o features.o multicalls.o mmu.o \
+obj-y		:= enlighten.o setup.o multicalls.o mmu.o \
 			events.o time.o manage.o xen-asm.o
 
 obj-$(CONFIG_SMP)	+= smp.o
diff --git a/drivers/xen/Makefile b/drivers/xen/Makefile
index 56592f0..609fdda 100644
--- a/drivers/xen/Makefile
+++ b/drivers/xen/Makefile
@@ -1,2 +1,2 @@
-obj-y	+= grant-table.o
+obj-y	+= grant-table.o features.o
 obj-y	+= xenbus/
diff --git a/arch/x86/xen/features.c b/drivers/xen/features.c
similarity index 100%
rename from arch/x86/xen/features.c
rename to drivers/xen/features.c
-- 
1.5.3

