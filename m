From: Lucas Woods <woodzy@gmail.com>
Date: Mon, 05 Nov 2007 20:13:28 +0000
Subject: [PATCH 03/12] arch/ia64: Remove duplicate includes.
Message-Id: <472F7968.1090408@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel-janitors@vger.kernel.org


Signed-off-by: Lucas Woods <woodzy@gmail.com>
---
 arch/ia64/ia32/ia32priv.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/ia32/ia32priv.h b/arch/ia64/ia32/ia32priv.h
index 466bbcb..c5c872b 100644
--- a/arch/ia64/ia32/ia32priv.h
+++ b/arch/ia64/ia32/ia32priv.h
@@ -290,7 +290,6 @@ struct old_linux32_dirent {
 #define _ASM_IA64_ELF_H		/* Don't include elf.h */
 
 #include <linux/sched.h>
-#include <asm/processor.h>
 
 /*
  * This is used to ensure we don't load something for the wrong architecture.
-- 


