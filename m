From: Akio Takebe <takebe_akio@jp.fujitsu.com>
Date: Wed, 27 Feb 2008 01:32:00 +0000
Subject: Re: [Xen-ia64-devel] [PATCH 7/8] ia64/xen: paravirtualize minstate.h, DO_SAVE_MIN.
Message-Id: <5C878E08C9E9Btakebe_akio@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, Isaku

>---
> arch/ia64/xen/xenminstate.h |  148 ++++++++++++++++++++++++++++++++++++++++
>+++
> 1 files changed, 148 insertions(+), 0 deletions(-)
> create mode 100644 arch/ia64/xen/xenminstate.h
>
>diff --git a/arch/ia64/xen/xenminstate.h b/arch/ia64/xen/xenminstate.h
>new file mode 100644
>index 0000000..cdaf910
>--- /dev/null
>+++ b/arch/ia64/xen/xenminstate.h
>@@ -0,0 +1,148 @@
>+#include <asm/cache.h>
>+
>+#ifdef CONFIG_XEN
>+#include "../kernel/entry.h"
>+#else
>+#include "entry.h"
>+#endif
>+
>
we don't have arch/ia64/xen/entry.h,
so the above ifdef is not necessary.

Best Regards,

Akio Takebe

