From: Keith Owens <kaos@sgi.com>
Date: Mon, 23 Feb 2004 23:53:33 +0000
Subject: Re: [patch] 2.6.3 sync unwind code with 2.4.25
Message-Id: <2108.1077580413@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4545.1077507994@kao2.melbourne.sgi.com>
In-Reply-To: <4545.1077507994@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 23 Feb 2004 15:34:40 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>Note that I added an unwind.c fix recently.

Before or after 2.6.3 was released?  All the 2.6.3 unwind bug fixes
were included in the sync patch that I sent to Bjorn.

>There is at least
>one more that needs to be backported from libunwind, but I want to
>complete the libunwind-testing before doing that.

One line fix for 2.6.3.  include/linux/compiler-gcc3.h defines inline
which gives warnings for unwind.c when UNW_DEBUG is defined.

Index: 3.1/arch/ia64/kernel/unwind.c
--- 3.1/arch/ia64/kernel/unwind.c Sun, 08 Feb 2004 22:59:56 +1100 kaos (linux-2.6/Z/c/10_unwind.c 1.1.1.2 644)
+++ 3.1(w)/arch/ia64/kernel/unwind.c Tue, 24 Feb 2004 10:36:33 +1100 kaos (linux-2.6/Z/c/10_unwind.c 1.1.1.2 644)
@@ -63,6 +63,7 @@
 #  define UNW_DEBUG_ON(n)	unw_debug_level >= n
    /* Do not code a printk level, not all debug lines end in newline */
 #  define UNW_DPRINT(n, ...)  if (UNW_DEBUG_ON(n)) printk(__VA_ARGS__)
+#  undef inline
 #  define inline
 #else /* !UNW_DEBUG */
 #  define UNW_DEBUG_ON(n)  0

