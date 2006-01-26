From: "David S. Miller" <davem@davemloft.net>
Date: Thu, 26 Jan 2006 00:04:30 +0000
Subject: Re: [PATCH 5/6] fix warning on test_ti_thread_flag()
Message-Id: <20060125.160430.94334986.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com>
	<20060125113446.GF18584@miraclelinux.com>
	<17367.64370.844350.972910@cargo.ozlabs.ibm.com>
In-Reply-To: <17367.64370.844350.972910@cargo.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: paulus@samba.org
Cc: mita@miraclelinux.com, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, spyro@f2s.com, dhowells@redhat.com, linuxppc-dev@ozlabs.org, gerg@uclinux.org, sparclinux@vger.kernel.org, uclinux-v850@lsi.nec.co.jp, torvalds@osdl.org, ysato@users.sourceforge.jp, takata@linux-m32r.org, linuxsh-shmedia-dev@lists.sourceforge.net, linux-m68k@vger.kernel.org, ink@jurassic.park.msu.ru, rth@twiddle.net, chris@zankel.net, dev-etrax@axis.com, ultralinux@vger.kernel.org, ak@suse.de, linuxsh-dev@lists.sourceforge.net, linux390@de.ibm.com, rmk@arm.linux.org.uk, parisc-linux@parisc-linux.org

From: Paul Mackerras <paulus@samba.org>
Date: Thu, 26 Jan 2006 09:28:02 +1100

> Akinobu Mita writes:
> 
> > If the arechitecture is
> > - BITS_PER_LONG = 64
> > - struct thread_info.flag 32 is bits
> > - second argument of test_bit() was void *
> > 
> > Then compiler print error message on test_ti_thread_flags()
> > in include/linux/thread_info.h
> 
> And correctly so.  The correct fix is to make thread_info.flag an
> unsigned long.  This patch is NAKed.

I agree.
