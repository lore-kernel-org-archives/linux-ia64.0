From: Robert Picco <Robert.Picco@hp.com>
Date: Sun, 12 Dec 2004 20:46:41 +0000
Subject: Re: [2.6 patch] ia64 smpboot.c: remove an unused function
Message-Id: <41BCAE31.7030702@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041212193921.GA22324@stusta.de>
In-Reply-To: <20041212193921.GA22324@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@stusta.de>
Cc: David Mosberger-Tang <davidm@hpl.hp.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Adrian Bunk wrote:

>The patch below removes an unused global functions.
>
>
>Signed-off-by: Adrian Bunk <bunk@stusta.de>
>
>--- linux-2.6.10-rc2-mm4-full/arch/ia64/kernel/smpboot.c.old	2004-12-12 02:51:04.000000000 +0100
>+++ linux-2.6.10-rc2-mm4-full/arch/ia64/kernel/smpboot.c	2004-12-12 02:51:18.000000000 +0100
>@@ -356,11 +356,6 @@
> 	return cpu_idle();
> }
> 
>-struct pt_regs * __devinit idle_regs(struct pt_regs *regs)
>-{
>-	return NULL;
>-}
>-
> struct create_idle {
> 	struct task_struct *idle;
> 	struct completion done;
>
>  
>
I don't believe this is unused.  At least not in 2.6.10-rc3.  fork_idle 
requires this function.

Bob
