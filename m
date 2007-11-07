From: Simon Horman <horms@verge.net.au>
Date: Wed, 07 Nov 2007 06:46:29 +0000
Subject: [patch] ia64: remove per_cpu_offset()
Message-Id: <20071107064627.GD3571@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Yu Luming <luming.yu@intel.com>, David Miller <davem@davemloft.net>, Ingo Molnar <mingo@elte.hu>, Arjan van de Ven <arjan@linux.intel.com>, Rusty Russell <rusty@rustcorp.com.au>, Andrew Morton <akpm@osdl.org>

per_cpu_offset() was added as part of a lockdep patch,
"[PATCH] lockdep: add per_cpu_offset()"
(a875a69f8b00a38b4f40d9632a4fc71a159f0e0d),
but ia64 doesn't have lockdep, nor does it use per_cpu_offset()
anywhere else.

This came up because Yu Lumming noticed that the ia64 version
of per_cpu_offset() actually has a syntax error. Amusing as it seems
to have been in the tree for months.

> -#define per_cpu_offset(x) (__per_cpu_offset(x))
> +#define per_cpu_offset(x) (__per_cpu_offset[x])

Dave Miller suggested that rather than fixing the unused code it would be
better to just remove it all together.

Signed-off-by: Simon Horman <horms@verge.net.au>

diff --git a/include/asm-ia64/percpu.h b/include/asm-ia64/percpu.h
index c4f1e32..2870f8d 100644
--- a/include/asm-ia64/percpu.h
+++ b/include/asm-ia64/percpu.h
@@ -46,7 +46,6 @@
 #ifdef CONFIG_SMP
 
 extern unsigned long __per_cpu_offset[NR_CPUS];
-#define per_cpu_offset(x) (__per_cpu_offset[x])
 
 /* Equal to __per_cpu_offset[smp_processor_id()], but faster to access: */
 DECLARE_PER_CPU(unsigned long, local_per_cpu_offset);
