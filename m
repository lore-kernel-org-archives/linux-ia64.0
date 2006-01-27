From: Hirokazu Takata <takata@linux-m32r.org>
Date: Fri, 27 Jan 2006 12:51:47 +0000
Subject: Re: [PATCH 3/6] C-language equivalents of include/asm-*/bitops.h
Message-Id: <20060127.215147.670306403.takata.hirokazu@renesas.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com>
	<20060125113206.GD18584@miraclelinux.com>
In-Reply-To: <20060125113206.GD18584@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mita@miraclelinux.com
Cc: linux-kernel@vger.kernel.org, rth@twiddle.net, ink@jurassic.park.msu.ru, rmk@arm.linux.org.uk, spyro@f2s.com, dev-etrax@axis.com, dhowells@redhat.com, ysato@users.sourceforge.jp, torvalds@osdl.org, linux-ia64@vger.kernel.org, takata@linux-m32r.org, linux-m68k@vger.kernel.org, gerg@uclinux.org, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, uclinux-v850@lsi.nec.co.jp, ak@suse.de, chris@zankel.net, akpm@osdl.org

Hello Mita-san, and folks,

From: mita@miraclelinux.com (Akinobu Mita)
Subject: [PATCH 3/6] C-language equivalents of include/asm-*/bitops.h
Date: Wed, 25 Jan 2006 20:32:06 +0900
> o generic {,test_and_}{set,clear,change}_bit() (atomic bitops)
> 
> This patch introduces the C-language equivalents of the functions below:
> void set_bit(int nr, volatile unsigned long *addr);
> void clear_bit(int nr, volatile unsigned long *addr);
...
> int test_and_change_bit(int nr, volatile unsigned long *addr);
> 
> HAVE_ARCH_ATOMIC_BITOPS is defined when the architecture has its own
> version of these functions.
> 
> This code largely copied from:
> include/asm-powerpc/bitops.h
> include/asm-parisc/bitops.h
> include/asm-parisc/atomic.h

Could you tell me more about the new generic {set,clear,test}_bit()
routines?

Why do you copied these routines from parisc and employed them
 as generic ones?
I'm not sure whether these generic {set,clear,test}_bit() routines
are really generic or not.

> +/* Can't use raw_spin_lock_irq because of #include problems, so
> + * this is the substitute */
> +#define _atomic_spin_lock_irqsave(l,f) do {	\
> +	raw_spinlock_t *s = ATOMIC_HASH(l);	\
> +	local_irq_save(f);			\
> +	__raw_spin_lock(s);			\
> +} while(0)
> +
> +#define _atomic_spin_unlock_irqrestore(l,f) do {	\
> +	raw_spinlock_t *s = ATOMIC_HASH(l);		\
> +	__raw_spin_unlock(s);				\
> +	local_irq_restore(f);				\
> +} while(0)

Is there a possibility that these routines affect for archs
with no HAVE_ARCH_ATOMIC_BITOPS for SMP ?
I think __raw_spin_lock() is sufficient and local_irqsave() is 
not necessary in general atomic routines.

If the parisc's LDCW instruction required disabling interrupts,
it would be parisc specific and not generic case, I think, 
although I'm not familier with the parisc architecture...

-- Takata
