From: Chris Down <chris@chrisdown.name>
Date: Fri, 26 Feb 2021 13:14:55 +0000
Subject: Re: [PATCH] ia64: Depend on non-static printk for cmpxchg debug
Message-Id: <YDj0T7H4ZbuEAYwK@chrisdown.name>
List-Id: <linux-ia64.vger.kernel.org>
References: <YCflN5zTvo5mxvKY@chrisdown.name>
 <YDjt/lI82VzZcCgq@chrisdown.name>
 <20210226130029.GC2723601@casper.infradead.org>
In-Reply-To: <20210226130029.GC2723601@casper.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Matthew Wilcox writes:
>Why not just fix it?
>
>diff --git a/arch/ia64/include/uapi/asm/cmpxchg.h b/arch/ia64/include/uapi/asm/cmpxchg.h
>index 5d90307fd6e0..d955a8e3ebde 100644
>--- a/arch/ia64/include/uapi/asm/cmpxchg.h
>+++ b/arch/ia64/include/uapi/asm/cmpxchg.h
>@@ -139,7 +139,7 @@ extern long ia64_cmpxchg_called_with_bad_pointer(void);
> do {									\
> 	if (_cmpxchg_bugcheck_count-- <= 0) {				\
> 		void *ip;						\
>-		extern int printk(const char *fmt, ...);		\
>+		int printk(const char *fmt, ...);			\
> 		ip = (void *) ia64_getreg(_IA64_REG_IP);		\
> 		printk("CMPXCHG_BUGCHECK: stuck at %p on word %p\n", ip, (v));\
> 		break;							\

I must confess I have no idea of the history of why it was `extern int` in the 
first place -- my fear was somehow we use cmpxchg.h from a different context.  
Do you have any idea? :-)
