From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 19 Jun 2008 12:10:04 +0000
Subject: Re: [PATCH 08/27] ia64/xen: define helper functions for xen hypercalls.
Message-Id: <20080619121004.GP11378%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12130840431025-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12130840431025-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 17, 2008 at 04:57:55PM -0700, Luck, Tony wrote:
> 
> +/*
> + * Hypercalls without parameter.
> + */
> +#define __HCALL0(name,hcall)           \
> +       GLOBAL_ENTRY(name);             \
> +       break   hcall;                  \
> 
> Should Linux code be made aware of the "break" numbers that
> are being used for hypercalls (so it doesn't try to re-use
> them for something else?)  include/asm-ia64/break.h should be
> updated with the appropriate stuff (just with a base value
> and a comment for how many you are using ... you can still
> define all the HYPERPRIVOP_* defines in a separate file).
> 
> -Tony

Here is the patch to reserve those numbers.

From 1c9b394c025bb9dcb29dc8240bda68117f577c9d Mon Sep 17 00:00:00 2001
From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 19 Jun 2008 19:07:37 +0900
Subject: [PATCH] ia64/xen: reserve "break" numbers used for xen hypercalls.

reserve "break" numbers used for xen hypercalls to avoid
reuse for something else.

Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/break.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/asm-ia64/break.h b/include/asm-ia64/break.h
index f034020..e90c40e 100644
--- a/include/asm-ia64/break.h
+++ b/include/asm-ia64/break.h
@@ -20,4 +20,13 @@
  */
 #define __IA64_BREAK_SYSCALL		0x100000
 
+/*
+ * Xen specific break numbers:
+ */
+#define __IA64_XEN_HYPERCALL		0x1000
+/* [__IA64_XEN_HYPERPRIVOP_START, __IA64_XEN_HYPERPRIVOP_MAX] is used
+   for xen hyperprivops */
+#define __IA64_XEN_HYPERPRIVOP_START	0x1
+#define __IA64_XEN_HYPERPRIVOP_MAX	0x1a
+
 #endif /* _ASM_IA64_BREAK_H */
-- 
1.5.3

-- 
yamahata
