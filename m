From: Martin Pool <mbp@sourcefrog.net>
Date: Fri, 16 Apr 2004 04:04:04 +0000
Subject: Re: bug? fpswa_interface needs to be exported
Message-Id: <20040416040403.GA12253@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040413073643.GB11350@hp.com>
In-Reply-To: <20040413073643.GB11350@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 13 Apr 2004, David Mosberger <davidm@napali.hpl.hp.com> wrote:
> >>>>> On Tue, 13 Apr 2004 17:36:43 +1000, Martin Pool <mbp@sourcefrog.net> said:
> 
>   Martin> Hi, In 2.6.4/5, efivars can be built as a module, but it
>   Martin> depends on 'fpswa_interface' which is not exported by
>   Martin> fpswa.c.  I think you need a EXPORT_SYMBOL for that
>   Martin> variable.
> 
>   Martin> Debian's 2.6.4-mckinley-smp kernel has this built as a
>   Martin> module but it cannot be loaded:
> 
>   Martin>   efivars: Unknown symbol fpswa_interface
> 
> Want to send a (tested) patch?

This will fix it:

--- linus--release--2.6.5--version-0/arch/ia64/kernel/traps.c	2004-04-15 12:42:32.000000000 +1000
+++ ./arch/ia64/kernel/traps.c	2004-04-15 16:18:55.000000000 +1000
@@ -13,6 +13,7 @@
 #include <linux/sched.h>
 #include <linux/tty.h>
 #include <linux/vt_kern.h>		/* For unblank_screen() */
+#include <linux/module.h>       /* for EXPORT_SYMBOL */
 
 #include <asm/fpswa.h>
 #include <asm/hardirq.h>
@@ -47,6 +48,7 @@
 extern spinlock_t timerlist_lock;
 
 fpswa_interface_t *fpswa_interface;
+EXPORT_SYMBOL(fpswa_interface);
 
 void __init
 trap_init (void)


There was also a bug in modpost that suppressed the warning that
should have come out at compile time.  Rusty has fixed it in Linus's
tree.

-- 
Martin 
