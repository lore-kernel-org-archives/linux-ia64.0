From: Brent Casavant <bcasavan@sgi.com>
Date: Thu, 01 Sep 2005 22:45:54 +0000
Subject: Re: [PATCH 2.6.13] IOCHK interface for I/O error handling/detecting
Message-Id: <20050901172917.I10072@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <431694DB.90400@jp.fujitsu.com>
In-Reply-To: <431694DB.90400@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>

On Thu, 1 Sep 2005, Hidetoshi Seto wrote:

> Index: linux-2.6.13/include/asm-ia64/io.h
> =================================> --- linux-2.6.13.orig/include/asm-ia64/io.h
> +++ linux-2.6.13/include/asm-ia64/io.h
> @@ -70,6 +70,26 @@ extern unsigned int num_io_spaces;
>  #include <asm/machvec.h>
>  #include <asm/page.h>
>  #include <asm/system.h>
> +
> +#ifdef CONFIG_IOMAP_CHECK
> +#include <linux/list.h>
> +#include <linux/spinlock.h>
> +
> +/* ia64 iocookie */
> +typedef struct {
> +	struct list_head	list;
> +	struct pci_dev		*dev;	/* target device */
> +	struct pci_dev		*host;	/* hosting bridge */
> +	unsigned long		error;	/* error flag */
> +} iocookie;
> +
> +extern rwlock_t iochk_lock;  /* see arch/ia64/lib/iomap_check.c */
> +
> +/* Enable ia64 iochk - See arch/ia64/lib/iomap_check.c */
> +#define HAVE_ARCH_IOMAP_CHECK
> +
> +#endif /* CONFIG_IOMAP_CHECK  */
> +
>  #include <asm-generic/iomap.h>
> 
>  /*
> @@ -164,14 +184,23 @@ __ia64_mk_io_addr (unsigned long port)
>   * during optimization, which is why we use "volatile" pointers.
>   */
> 
> +#ifdef CONFIG_IOMAP_CHECK
> +
> +extern void ia64_mca_barrier(unsigned long value);
> +
>  static inline unsigned int
>  ___ia64_inb (unsigned long port)
>  {
>  	volatile unsigned char *addr = __ia64_mk_io_addr(port);
>  	unsigned char ret;
> +	unsigned long flags;
> 
> +	read_lock_irqsave(&iochk_lock,flags);
>  	ret = *addr;
>  	__ia64_mf_a();
> +	ia64_mca_barrier(ret);
> +	read_unlock_irqrestore(&iochk_lock,flags);
> +
>  	return ret;
>  }
> 
> @@ -180,9 +209,14 @@ ___ia64_inw (unsigned long port)
>  {
>  	volatile unsigned short *addr = __ia64_mk_io_addr(port);
>  	unsigned short ret;
> +	unsigned long flags;
> 
> +	read_lock_irqsave(&iochk_lock,flags);
>  	ret = *addr;
>  	__ia64_mf_a();
> +	ia64_mca_barrier(ret);
> +	read_unlock_irqrestore(&iochk_lock,flags);
> +
>  	return ret;
>  }
> 
> @@ -191,12 +225,54 @@ ___ia64_inl (unsigned long port)
>  {
>  	volatile unsigned int *addr = __ia64_mk_io_addr(port);
>  	unsigned int ret;
> +	unsigned long flags;
> 
> +	read_lock_irqsave(&iochk_lock,flags);
>  	ret = *addr;
>  	__ia64_mf_a();
> +	ia64_mca_barrier(ret);
> +	read_unlock_irqrestore(&iochk_lock,flags);
> +
>  	return ret;
>  }

I am extremely concerned about the performance implications of this
implementation.  These changes have several deleterious effects on I/O
performance.

The first is serialization of all I/O reads and writes.  This will
be a severe problem on systems with large numbers of PCI buses, the
very type of system that stands the most to gain in reliability from
these efforts.  At a minimum any locking should be done on a per-bus
basis.

The second is the raw performance penalty from acquiring and dropping
a lock with every read and write.  This will be a substantial amount
of activity for any I/O-intensive system, heck even for moderate I/O
levels.

The third is lock contention for this single lock -- I would fully expect
many dozens of processors to be performing I/O at any given time on
systems of interest, causing this to be a heavily contended lock.
This will be even more severe on NUMA systems, as the lock cacheline
bounces across the memory fabric.  A per-bus lock would again be much
more appropriate.

The final problem is that these performance penalties are paid even
by drivers which are not IOCHK aware, which for the time being is
all of them.  A reasonable solution must pay these penalties only
for drivers which are IOCHK aware.  Reinstating the readX_check()
interface is the obvious solution here.  It's simply too heavy a
performance burden to pay when almost no drivers currently benefit
from it.

Otherwise, I also wonder if you have any plans to handle similar
errors experienced under device-initiated DMA, or asynchronous I/O.
It's not clear that there's sufficient infrastructure in the current
patches to adequately handle those situations.

Thank you,
Brent Casavant

-- 
Brent Casavant                          If you had nothing to fear,
bcasavan@sgi.com                        how then could you be brave?
Silicon Graphics, Inc.                    -- Queen Dama, Source Wars
