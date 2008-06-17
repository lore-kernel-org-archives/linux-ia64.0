From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 17 Jun 2008 23:57:55 +0000
Subject: RE: [PATCH 08/27] ia64/xen: define helper functions for xen
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3061C5C5D@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12130840431025-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12130840431025-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


+/*
+ * Hypercalls without parameter.
+ */
+#define __HCALL0(name,hcall)           \
+       GLOBAL_ENTRY(name);             \
+       break   hcall;                  \

Should Linux code be made aware of the "break" numbers that
are being used for hypercalls (so it doesn't try to re-use
them for something else?)  include/asm-ia64/break.h should be
updated with the appropriate stuff (just with a base value
and a comment for how many you are using ... you can still
define all the HYPERPRIVOP_* defines in a separate file).

-Tony
