From: Paul Mackerras <paulus@samba.org>
Date: Wed, 25 Jan 2006 22:28:02 +0000
Subject: Re: [PATCH 5/6] fix warning on test_ti_thread_flag()
Message-Id: <17367.64370.844350.972910@cargo.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com>
	<20060125113446.GF18584@miraclelinux.com>
In-Reply-To: <20060125113446.GF18584@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Akinobu Mita <mita@miraclelinux.com>
Cc: linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, Ian Molton <spyro@f2s.com>, David Howells <dhowells@redhat.com>, linuxppc-dev@ozlabs.org, Greg Ungerer <gerg@uclinux.org>, sparclinux@vger.kernel.org, Miles Bader <uclinux-v850@lsi.nec.co.jp>, Linus Torvalds <torvalds@osdl.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, linuxsh-shmedia-dev@lists.sourceforge.net, linux-m68k@vger.kernel.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Richard Henderson <rth@twiddle.net>, Chris Zankel <chris@zankel.net>, dev-etrax@axis.com, ultralinux@vger.kernel.org, Andi Kleen <ak@suse.de>, linuxsh-dev@lists.sourceforge.net, linux390@de.ibm.com, Russell King <rmk@arm.linux.org.uk>, parisc-linux@parisc-linux.org

Akinobu Mita writes:

> If the arechitecture is
> - BITS_PER_LONG = 64
> - struct thread_info.flag 32 is bits
> - second argument of test_bit() was void *
> 
> Then compiler print error message on test_ti_thread_flags()
> in include/linux/thread_info.h

And correctly so.  The correct fix is to make thread_info.flag an
unsigned long.  This patch is NAKed.

Paul.
