From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 17 Oct 2001 15:00:09 +0000
Subject: [Linux-ia64] Re: console_loglevel is broken on ia64
Message-Id: <marc-linux-ia64-105590698805360@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805358@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805358@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 17 Oct 2001, Keith Owens wrote:
> kernel/printk.c has this abomination.
> 
> /* Keep together for sysctl support */
> int console_loglevel = DEFAULT_CONSOLE_LOGLEVEL;
> int default_message_loglevel = DEFAULT_MESSAGE_LOGLEVEL;
> int minimum_console_loglevel = MINIMUM_CONSOLE_LOGLEVEL;
> int default_console_loglevel = DEFAULT_CONSOLE_LOGLEVEL;
> 
> sysctl assumes that the 4 variables occupy contiguous storage.  They
> don't on ia64, console_loglevel is separate from the other variables.
> 
>   echo 6 4 1 7 > /proc/sys/kernel/printk
>   
> on ia64 overwrites console_loglevel and the next 3 integers, whatever
> they happen to be.  On 2.4.12 it corrupts console_sem, other ia64
> kernels will corrupt different data.
> 
> Does anybody fancy a small project to clean up these variables?  They
> need to become an integer array (say console_printk) containing 4
> elements, which is what sysctl assumes.  All references to these fields
> have to be changed to refer to the corresponding array element.  That
> should be as simple as

This is not the only problem related to sysctl. We still have

    {KERN_REALROOTDEV, "real-root-dev", &real_root_dev, sizeof(int)

in kernel/sysctl.c, with

    kdev_t real_root_dev;

in init/main.c,

    extern kdev_t real_root_dev;
    
in drivers/block/rd.c, and

    typedef unsigned short kdev_t;
    
in <linux/kdev_t.h>. Kaboom on big endian boxes, escpecially if the alignment
rules are 2-bytes, like on m68k.

In the m68k tree we have (since ages) a patch to change real_root_dev to int
and add some casts. Patch available upon request.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds


