From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 14 Nov 2006 17:41:15 +0000
Subject: RE: [PATCH] ia64 enable trap code on slot 1
Message-Id: <617E1C2C70743745A92448908E030B2ACBEEBA@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <45592018.3040203@intel.com>
In-Reply-To: <45592018.3040203@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I think a comment here in break.h would be useful ... noting that
> for JPROBE and KPROBE the low 12-bits are ignored.

I added a teeny comment ... so break.h diff looks like this.  Ok?

diff --git a/include/asm-ia64/break.h b/include/asm-ia64/break.h
index 8167828..f034020 100644
--- a/include/asm-ia64/break.h
+++ b/include/asm-ia64/break.h
@@ -12,8 +12,8 @@ #define _ASM_IA64_BREAK_H
  * OS-specific debug break numbers:
  */
 #define __IA64_BREAK_KDB		0x80100
-#define __IA64_BREAK_KPROBE		0x80200
-#define __IA64_BREAK_JPROBE		0x80300
+#define __IA64_BREAK_KPROBE		0x81000 /* .. 0x81fff */
+#define __IA64_BREAK_JPROBE		0x82000
 
