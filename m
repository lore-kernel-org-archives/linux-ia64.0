From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 15 Sep 2009 17:27:10 +0000
Subject: Re: [PATCH] cleanup legacy console_print function
Message-Id: <200909151127.10697.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <DDFD17CC94A9BD49A82147DDF7D545C501F0FF17@exchange.ZeugmaSystems.local>
In-Reply-To: <DDFD17CC94A9BD49A82147DDF7D545C501F0FF17@exchange.ZeugmaSystems.local>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anirban Sinha <ASinha@zeugmasystems.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Randy Dunlap <randy.dunlap@oracle.com>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

On Monday 14 September 2009 12:28:21 pm Anirban Sinha wrote:
> From e096c1774450f8348a7af3b7e47800710a490212 Mon Sep 17 00:00:00 2001
> From: Anirban Sinha <asinha@zeugmasystems.com>
> Date: Mon, 14 Sep 2009 11:13:37 -0700
> Subject: cleanup console_print()
> 
> console_print() is an old legacy interface mostly unused in the entire
> kernel tree. It's best to clean up its existing use and let developers
> use their own implementation of it as they feel fit.

This broke the ia64 build, please fix:

arch/ia64/kernel/head.h: Assembler messages:
arch/ia64/kernel/head.h:1: Error: Unknown opcode `extern void console_print(const char*s)'
make[1]: *** [arch/ia64/kernel/head.o] Error 1
make[1]: *** Waiting for unfinished jobs....

Bjorn


> ---
>  arch/ia64/kernel/head.S    |    1 +
>  arch/ia64/kernel/head.h    |    1 +
>  arch/ia64/kernel/process.c |    7 +++++++
>  drivers/char/serial167.c   |    5 ++---
>  include/linux/dtlk.h       |   19 -------------------
>  include/linux/tty.h        |    4 ----
>  kernel/printk.c            |    6 ------
>  7 files changed, 11 insertions(+), 32 deletions(-)
>  create mode 100644 arch/ia64/kernel/head.h
> 
> diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
> index 23f846d..e6c5c3d 100644
> --- a/arch/ia64/kernel/head.S
> +++ b/arch/ia64/kernel/head.S
> @@ -34,6 +34,7 @@
>  #include <asm/mca_asm.h>
>  #include <linux/init.h>
>  #include <linux/linkage.h>
> +#include "head.h"
>  
>  #ifdef CONFIG_HOTPLUG_CPU
>  #define SAL_PSR_BITS_TO_SET				\
> diff --git a/arch/ia64/kernel/head.h b/arch/ia64/kernel/head.h
> new file mode 100644
> index 0000000..2e2ac68
> --- /dev/null
> +++ b/arch/ia64/kernel/head.h
> @@ -0,0 +1 @@
> +extern void console_print(const char *s);
> diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
> index 89969e9..b34bef7 100644
> --- a/arch/ia64/kernel/process.c
> +++ b/arch/ia64/kernel/process.c
> @@ -161,6 +161,13 @@ show_regs (struct pt_regs *regs)
>  		show_stack(NULL, NULL);
>  }
>  
> +/* local support for deprecated console_print */
> +void 
> +console_print(const char *s)
> +{
> +	printk(KERN_EMERG "%s", s);
> +}
> +
>  void
>  do_notify_resume_user(sigset_t *unused, struct sigscratch *scr, long
> in_syscall)
>  {
> diff --git a/drivers/char/serial167.c b/drivers/char/serial167.c
> index 51e7a46..5942a9d 100644
> --- a/drivers/char/serial167.c
> +++ b/drivers/char/serial167.c
> @@ -171,7 +171,6 @@ static int startup(struct cyclades_port *);
>  static void cy_throttle(struct tty_struct *);
>  static void cy_unthrottle(struct tty_struct *);
>  static void config_setup(struct cyclades_port *);
> -extern void console_print(const char *);
>  #ifdef CYCLOM_SHOW_STATUS
>  static void show_status(int);
>  #endif
> @@ -245,7 +244,7 @@ void SP(char *data)
>  {
>  	unsigned long flags;
>  	local_irq_save(flags);
> -	console_print(data);
> +	printk(KERN_EMERG "%s", data);
>  	local_irq_restore(flags);
>  }
>  
> @@ -255,7 +254,7 @@ void CP(char data)
>  	unsigned long flags;
>  	local_irq_save(flags);
>  	scrn[0] = data;
> -	console_print(scrn);
> +	printk(KERN_EMERG "%c", scrn);
>  	local_irq_restore(flags);
>  }				/* CP */
>  
> diff --git a/include/linux/dtlk.h b/include/linux/dtlk.h
> index 2896d90..22a7b9a 100644
> --- a/include/linux/dtlk.h
> +++ b/include/linux/dtlk.h
> @@ -1,22 +1,3 @@
> -#if 0
> -
> -#define TRACE_TXT(text) \
> -	{ \
> -	  if(dtlk_trace) \
> -	  { \
> -	    console_print(text); \
> -	    console_print("\n"); \
> -	  } \
> -	}
> -
> -#define TRACE_CHR(chr) \
> -	{ \
> -	  if(dtlk_trace) \
> -	    console_print(chr); \
> -	} \
> -
> -#endif
> -
>  #define DTLK_MINOR	0
>  #define DTLK_IO_EXTENT	0x02
>  
> diff --git a/include/linux/tty.h b/include/linux/tty.h
> index 0d3974f..a916a31 100644
> --- a/include/linux/tty.h
> +++ b/include/linux/tty.h
> @@ -519,10 +519,6 @@ extern void serial_console_init(void);
>  
>  extern int pcxe_open(struct tty_struct *tty, struct file *filp);
>  
> -/* printk.c */
> -
> -extern void console_print(const char *);
> -
>  /* vt.c */
>  
>  extern int vt_ioctl(struct tty_struct *tty, struct file *file,
> diff --git a/kernel/printk.c b/kernel/printk.c
> index e10d193..602033a 100644
> --- a/kernel/printk.c
> +++ b/kernel/printk.c
> @@ -1075,12 +1075,6 @@ void __sched console_conditional_schedule(void)
>  }
>  EXPORT_SYMBOL(console_conditional_schedule);
>  
> -void console_print(const char *s)
> -{
> -	printk(KERN_EMERG "%s", s);
> -}
> -EXPORT_SYMBOL(console_print);
> -
>  void console_unblank(void)
>  {
>  	struct console *c;


