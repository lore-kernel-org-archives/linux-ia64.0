From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 03:57:42 +0000
Subject: Re: [PATCH 24/28] ia64/xen: time paravirtualization
Message-Id: <20080222035742.GC2406%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <47BE0508.7080203@goop.org>
In-Reply-To: <47BE0508.7080203@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 21, 2008 at 03:11:04PM -0800, Jeremy Fitzhardinge wrote:
> yamahata@valinux.co.jp wrote:
> >diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
> >index 17fda52..1bb0362 100644
> >--- a/arch/ia64/kernel/time.c
> >+++ b/arch/ia64/kernel/time.c
> >@@ -29,6 +29,14 @@
> > #include <asm/sections.h>
> > #include <asm/system.h>
> > 
> >+#include <asm/xen/hypervisor.h>
> >+#ifdef CONFIG_XEN
> >+#include <linux/kernel_stat.h>
> >+#include <linux/posix-timers.h>
> >+#include <xen/interface/vcpu.h>
> >+#include <asm/percpu.h>
> >+#endif
> >+
> 
> ia64 doesn't use clocksources yet?  Couldn't you share a lot of this 
> with the 32-bit Xen time code (esp stolen time accounting)?

It does. I'll look into sharing code.
(Probably after cpu paravirtualization)

-- 
yamahata
