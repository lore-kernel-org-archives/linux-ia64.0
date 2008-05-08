From: Alex Chiang <achiang@hp.com>
Date: Thu, 08 May 2008 20:03:23 +0000
Subject: Re: [PATCH] ia64: allow user to skip_check_sal_cache_flush
Message-Id: <20080508200323.GD17222@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080507233614.GF5609@ldl.fc.hp.com>
In-Reply-To: <20080507233614.GF5609@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Luck, Tony <tony.luck@intel.com>:
> > +early_param("skip_check_sal_cache_flush", skip_check_sal_cache_flush);
> 
> Please document this in Documentation/kernel-paramters.txt
> 
> Perhaps this would set the record for the longest kenrel parameter,
> but I don't think this is a good thing.  Can you abbreviate while
> still being descriptive?

Sure, how about force_pal_cache_flush? It saves 5 chars and is
more explicit about what you're doing.

/ac

From: Alex Chiang <achiang@hp.com>
Subject: ia64: allow user to force_pal_cache_flush

The sequence executed in check_sal_cache_flush:

	- pend a timer interrupt
	- call SAL_CACHE_FLUSH
	- see if interrupt is still pending

can hang HP machines with buggy SAL_CACHE_FLUSH implementations.

Provide a kernel command-line argument to allow users skip this
check if desired. Using this parameter will force ia64_sal_cache_flush
to call ia64_pal_cache_flush() instead of SAL_CACHE_FLUSH.

Signed-off-by: Alex Chiang <achiang@hp.com>
---
diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index cdd5b93..654d630 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -689,6 +689,12 @@ and is between 256 and 4096 characters. It is defined in the file
 	floppy=		[HW]
 			See Documentation/floppy.txt.
 
+	force_pal_cache_flush
+			[IA-64] Avoid check_sal_cache_flush which may hang on
+			buggy SAL_CACHE_FLUSH implementations. Using this
+			parameter will force ia64_sal_cache_flush to call
+			ia64_pal_cache_flush instead of SAL_CACHE_FLUSH.
+
 	gamecon.map[2|3] 			[HW,JOY] Multisystem joystick and NES/SNES/PSX pad
 			support via parallel port (up to 5 devices per port)
diff --git a/arch/ia64/kernel/sal.c b/arch/ia64/kernel/sal.c
index a3022dc..7e02597 100644
--- a/arch/ia64/kernel/sal.c
+++ b/arch/ia64/kernel/sal.c
@@ -229,6 +229,14 @@ static void __init sal_desc_ap_wakeup(void *p) { }
  */
 static int sal_cache_flush_drops_interrupts;
 
+static int __init
+force_pal_cache_flush(char *str)
+{
+	sal_cache_flush_drops_interrupts = 1;
+	return 0;
+}
+early_param("force_pal_cache_flush", force_pal_cache_flush);
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
 
