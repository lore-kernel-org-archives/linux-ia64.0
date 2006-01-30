From: mita@miraclelinux.com (Akinobu Mita)
Date: Mon, 30 Jan 2006 03:15:22 +0000
Subject: Re: [PATCH 4/6] use include/asm-generic/bitops for each architecture
Message-Id: <20060130031522.GA6897@miraclelinux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com> <20060125113336.GE18584@miraclelinux.com> <20060126014934.GA6648@miraclelinux.com> <20060127.220401.356433243.takata.hirokazu@renesas.com>
In-Reply-To: <20060127.220401.356433243.takata.hirokazu@renesas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hirokazu Takata <takata@linux-m32r.org>
Cc: linux-kernel@vger.kernel.org, rth@twiddle.net, ink@jurassic.park.msu.ru, rmk@arm.linux.org.uk, spyro@f2s.com, dev-etrax@axis.com, dhowells@redhat.com, ysato@users.sourceforge.jp, torvalds@osdl.org, linux-ia64@vger.kernel.org, linux-m68k@vger.kernel.org, gerg@uclinux.org, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, uclinux-v850@lsi.nec.co.jp, ak@suse.de, chris@zankel.net, akpm@osdl.org

On Fri, Jan 27, 2006 at 10:04:01PM +0900, Hirokazu Takata wrote:

> compile and boot test on m32r: OK

Thanks.

> Code size became a little bigger...  ;-)
> 
> $ size linux-2.6.16-rc1*/vmlinux
>    text    data     bss     dec     hex filename
> 1768030  124412  721632 2614074  27e33a linux-2.6.16-rc1.bitops/vmlinux
> 1755010  124412  721632 2601054  27b05e linux-2.6.16-rc1.org/vmlinux

The only difference I can find is __ffs()/ffz().
As Russel King clealy pointed out, it will generate larger code
than before.

