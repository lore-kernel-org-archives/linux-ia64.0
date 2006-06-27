From: Horms <horms@verge.net.au>
Date: Tue, 27 Jun 2006 03:40:12 +0000
Subject: [PATCH] ia64, kexec: elfcoreheader needs CONFIG_PROC_VMCORE rather than CONFIG_CRASH_DUMP
Message-Id: <20060627034010.GA28249@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[ I feel like I have de-ja-vu here, as I swear I sent this once before,
  but I can't find it anywhere. ]

elfcorehdr is part of CONFIG_PROC_VMCORE not CONFIG_CRASH_DUMP, the
current code will fail to build if CONFIG_CRASH_DUMP is defined but
CONFIG_PROC_VMCORE is not.

Signed-off-by: Horms <horms@verge.net.au>
---
 arch/ia64/kernel/setup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index beea1d1..879c8de 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -513,7 +513,7 @@ #endif
 	if (!nomca)
 		ia64_mca_init();
 
-#ifdef CONFIG_CRASH_DUMP
+#ifdef CONFIG_PROC_VMCORE
 	{
 		char *from = strstr(saved_command_line, "elfcorehdr=");
 
-- 
1.4.1.rc1.g1ef9

