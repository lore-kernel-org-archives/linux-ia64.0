From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 08 May 2007 18:03:20 +0000
Subject: RE: [PATCH Resend] - SN: validate smp_affinity mask on intr redirect
Message-Id: <617E1C2C70743745A92448908E030B2A01719A90@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20070508152315.26329.8428.64771@attica.americas.sgi.com>
References: <20070508152315.26329.8428.64771@attica.americas.sgi.com>
In-Reply-To: <20070508152315.26329.8428.64771@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Keller <jpk@sgi.com>, linux-kernel@vger.kernel.org
Cc: akpm@osdl.org, steiner@sgi.com, linux-ia64@vger.kernel.org

 
+#ifndef is_affinity_mask_valid
+#define is_affinity_mask_valid() 1
+#endif
+
 int no_irq_affinity;
 static int irq_affinity_write_proc(struct file *file, const char __user *buffer,
 				   unsigned long count, void *data)
@@ -42,6 +46,9 @@ static int irq_affinity_write_proc(struc
 	if (err)
 		return err;
 
+	if (!is_affinity_mask_valid(new_value))
+		return -EINVAL;

This results in a warning:
kernel/irq/proc.c:49: warning: implicit declaration of function `is_affinity_mask_valid'

I can't put a declaration for is_affinity_mask_valid into
include/asm-ia64/irq.h because that results in errors in
files that include this, but don't have a definition for
cpumask_t.

I could add the declaration as a #else clause to that
#ifndef in kernel/irq/proc.c, but that would no doubt
result is complaints from the style police that function
prototypes belong in header files, not in ".c" files.

Last option is to move the #if to linux/irq.h:

#ifndef is_affinity_mask_valid
#define is_affinity_mask_valid 1
#else
extern bool is_affinity_mask_valid(cpumask_t cpumask);
#endif

But that seems to spoil the whole tricksiness factor and
doesn't really look any better that using ARCH_HAS_IRQ_AFFINITY_MASK_CHECK

-Tony
