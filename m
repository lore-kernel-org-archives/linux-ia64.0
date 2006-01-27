From: Hirokazu Takata <takata@linux-m32r.org>
Date: Fri, 27 Jan 2006 13:04:01 +0000
Subject: Re: [PATCH 4/6] use include/asm-generic/bitops for each
Message-Id: <20060127.220401.356433243.takata.hirokazu@renesas.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com>
	<20060125113336.GE18584@miraclelinux.com>
	<20060126014934.GA6648@miraclelinux.com>
In-Reply-To: <20060126014934.GA6648@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mita@miraclelinux.com
Cc: linux-kernel@vger.kernel.org, rth@twiddle.net, ink@jurassic.park.msu.ru, rmk@arm.linux.org.uk, spyro@f2s.com, dev-etrax@axis.com, dhowells@redhat.com, ysato@users.sourceforge.jp, torvalds@osdl.org, linux-ia64@vger.kernel.org, takata@linux-m32r.org, linux-m68k@vger.kernel.org, gerg@uclinux.org, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, uclinux-v850@lsi.nec.co.jp, ak@suse.de, chris@zankel.net, akpm@osdl.org

From: mita@miraclelinux.com (Akinobu Mita)
Subject: Re: [PATCH 4/6] use include/asm-generic/bitops for each architecture
Date: Thu, 26 Jan 2006 10:49:34 +0900
> On Wed, Jan 25, 2006 at 08:33:37PM +0900, mita wrote:
> > compile test on i386, x86_64, ppc, sparc, sparc64, alpha
> > boot test on i386, x86_64, ppc
...
>
> o m32r
> 
> - remove __{,test_and_}{set,clear,change}_bit() and test_bit()
> - remove ffz()
> - remove find_{next,first}{,_zero}_bit()
> - remove __ffs()
> - remove fls()
> - remove fls64()
> - remove sched_find_first_bit()
> - remove ffs()
> - remove hweight()
> - remove ext2_{set,clear,test,find_first_zero,find_next_zero}_bit()
> - remove ext2_{set,clear}_bit_atomic()
> - remove minix_{test,set,test_and_clear,test,find_first_zero}_bit()
> - define HAVE_ARCH_ATOMIC_BITOPS
> 

compile and boot test on m32r: OK

Code size became a little bigger...  ;-)

$ size linux-2.6.16-rc1*/vmlinux
   text    data     bss     dec     hex filename
1768030  124412  721632 2614074  27e33a linux-2.6.16-rc1.bitops/vmlinux
1755010  124412  721632 2601054  27b05e linux-2.6.16-rc1.org/vmlinux

-- Takata

