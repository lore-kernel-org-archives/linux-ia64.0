From: Alex Chiang <achiang@hp.com>
Date: Wed, 07 May 2008 23:36:14 +0000
Subject: [PATCH] ia64: allow user to skip_check_sal_cache_flush
Message-Id: <20080507233614.GF5609@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

A long time ago, when check_sal_cache_flush() was added to work
around some broken HP firmware, that workaround broke some other
HP platforms with different broken firmware (notably, the
rx2600). :-/

There's a firmware fix for the machines in that second category,
but if the fix isn't applied and the user attempts to boot a
modern kernel, they'll hang.

We also have some HP protos that were never shipped, who will
never get an updated firmware, but are actually still useful,
assuming we can get them to boot. ;)

It would be nice to get this patch in mainline, so people with
known broken firmware can avoid the logic in check_sal_cache_flush
if necessary.

Thanks.

/ac

From: Alex Chiang <achiang@hp.com>

The sequence executed in check_sal_cache_flush:

	- pend a timer interrupt
	- call SAL_CACHE_FLUSH
	- see if interrupt is still pending

can hang HP machines with buggy SAL_CACHE_FLUSH implementations.

Provide a kernel command-line argument to allow users skip this
check if desired.

Signed-off-by: Alex Chiang <achiang@hp.com>
---
diff --git a/arch/ia64/kernel/sal.c b/arch/ia64/kernel/sal.c
index a3022dc..65163b7 100644
--- a/arch/ia64/kernel/sal.c
+++ b/arch/ia64/kernel/sal.c
@@ -229,6 +229,14 @@ static void __init sal_desc_ap_wakeup(void *p) { }
  */
 static int sal_cache_flush_drops_interrupts;
 
+static int __init
+skip_check_sal_cache_flush(char *str)
+{
+	sal_cache_flush_drops_interrupts = 1;
+	return 0;
+}
+early_param("skip_check_sal_cache_flush", skip_check_sal_cache_flush);
+
 void __init
 check_sal_cache_flush (void)
 {
@@ -237,6 +245,9 @@ check_sal_cache_flush (void)
 	u64 vector, cache_type = 3;
 	struct ia64_sal_retval isrv;
 
+	if (sal_cache_flush_drops_interrupts)
+		return;
+
 	cpu = get_cpu();
 	local_irq_save(flags);
 
