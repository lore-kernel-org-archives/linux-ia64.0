From: Matthew Wilcox <willy@infradead.org>
Date: Fri, 26 Feb 2021 13:00:29 +0000
Subject: Re: [PATCH] ia64: Depend on non-static printk for cmpxchg debug
Message-Id: <20210226130029.GC2723601@casper.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <YCflN5zTvo5mxvKY@chrisdown.name>
 <YDjt/lI82VzZcCgq@chrisdown.name>
In-Reply-To: <YDjt/lI82VzZcCgq@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Feb 26, 2021 at 12:47:58PM +0000, Chris Down wrote:
> >    ./include/linux/printk.h:219:5: error: static declaration of 'printk' follows non-static declaration
> >    219 | int printk(const char *s, ...)
> > 	|     ^~~~~~
> >    ./arch/ia64/include/uapi/asm/cmpxchg.h:142:14: note: previous declaration of 'printk' was here
> >    142 |   extern int printk(const char *fmt, ...);  \
> > 	|              ^~~~~~
> > 
> > Make CONFIG_IA64_DEBUG_CMPXCHG dependent on CONFIG_PRINTK to avoid this.

Why not just fix it?

diff --git a/arch/ia64/include/uapi/asm/cmpxchg.h b/arch/ia64/include/uapi/asm/cmpxchg.h
index 5d90307fd6e0..d955a8e3ebde 100644
--- a/arch/ia64/include/uapi/asm/cmpxchg.h
+++ b/arch/ia64/include/uapi/asm/cmpxchg.h
@@ -139,7 +139,7 @@ extern long ia64_cmpxchg_called_with_bad_pointer(void);
 do {									\
 	if (_cmpxchg_bugcheck_count-- <= 0) {				\
 		void *ip;						\
-		extern int printk(const char *fmt, ...);		\
+		int printk(const char *fmt, ...);			\
 		ip = (void *) ia64_getreg(_IA64_REG_IP);		\
 		printk("CMPXCHG_BUGCHECK: stuck at %p on word %p\n", ip, (v));\
 		break;							\
