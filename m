From: mcgrof@kernel.org
Date: Fri, 19 Aug 2016 21:32:50 +0000
Subject: [PATCH v4 01/16] x86: remove LTO_REFERENCE_INITCALL()
Message-Id: <1471642385-5629-2-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642385-5629-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1471642385-5629-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: gnomes@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, linux@rasmusvillemoes.dk, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, sparclinux@vger.kernel.org, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, xen-devel@lists.xensource.com, msalter@redhat.com, linux-sh@vger.kernel.org, mpe@ellerman.id.au, x86@kernel.org, fontana@sharpeleven.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, linux-xtensa@linux-xtensa.org, pali.rohar@gmail.com, keescook@chromium.org, arnd@arndb.de, jani.nikula@intel.com, will.deacon@arm.com, rusty@rustcorp.com.au, rostedt@goodmis.org, acme@redhat.com, ak@linux.intel.com, andriy.shevchenko@linux.intel.com, mcb30@ip

From: "Luis R. Rodriguez" <mcgrof@kernel.org>

The setup for LTO never made it upstream, and although this has
some users, this is now really old stuff for a gcc 4.7 LTO problem.
We know that at least LTO_REFERENCE_INITCALL() work around can
be removed if LTO is not supported on v4.7 anymore.

As per Andi the DISABLE_LTO and LTO_CFLAGS are still neeeded though.

v3: added to this series, removing LTO_REFERENCE_INITCALL()
    justifies that other future similar macros do not need
    a respective LTO_REFERENCE_INITCALL() on them therefore
    simplifying new code.

Acked-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 include/linux/init.h | 20 +-------------------
 1 file changed, 1 insertion(+), 19 deletions(-)

diff --git a/include/linux/init.h b/include/linux/init.h
index 1e5c131d5c9a..aa662ad80d9c 100644
--- a/include/linux/init.h
+++ b/include/linux/init.h
@@ -151,23 +151,6 @@ extern bool initcall_debug;
 
 #ifndef __ASSEMBLY__
 
-#ifdef CONFIG_LTO
-/* Work around a LTO gcc problem: when there is no reference to a variable
- * in a module it will be moved to the end of the program. This causes
- * reordering of initcalls which the kernel does not like.
- * Add a dummy reference function to avoid this. The function is
- * deleted by the linker.
- */
-#define LTO_REFERENCE_INITCALL(x) \
-	; /* yes this is needed */			\
-	static __used __exit void *reference_##x(void)	\
-	{						\
-		return &x;				\
-	}
-#else
-#define LTO_REFERENCE_INITCALL(x)
-#endif
-
 /* initcalls are now grouped by functionality into separate 
  * subsections. Ordering inside the subsections is determined
  * by link order. 
@@ -180,8 +163,7 @@ extern bool initcall_debug;
 
 #define __define_initcall(fn, id) \
 	static initcall_t __initcall_##fn##id __used \
-	__attribute__((__section__(".initcall" #id ".init"))) = fn; \
-	LTO_REFERENCE_INITCALL(__initcall_##fn##id)
+	__attribute__((__section__(".initcall" #id ".init"))) = fn;
 
 /*
  * Early initcalls run before initializing SMP.
-- 
2.9.2

