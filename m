From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 14 Oct 2008 21:46:41 +0000
Subject: RE: [PATCH 09/32] ia64/xen: add a necessary header file to compile
Message-Id: <57C9024A16AD2D4C97DC78E552063EA353274D0A@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1223963507-28056-10-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1223963507-28056-10-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

+++ b/arch/ia64/include/asm/pvclock-abi.h
@@ -0,0 +1,5 @@
+/*
+ * use same structure to x86's
+ * Hopefully asm-x86/pvclock-abi.h would be moved to somewhere more generic.
+ */
+#include <asm-x86/pvclock-abi.h>


I will trade out this patch for one that just makes
a copy of the x86 include file.  This #include will
break if/when x86 moves their include files to
arch/x86/include/asm

-Tony
