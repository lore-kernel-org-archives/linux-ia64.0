From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 21 Oct 2004 08:03:25 +0000
Subject: Re: [discuss] Re: [PATCH] Add key management syscalls to non-i386
Message-Id: <Pine.GSO.4.61.0410211002020.614@waterleaf.sonytel.be>
List-Id: <linux-ia64.vger.kernel.org>
References: <3506.1098283455@redhat.com> <20041020150149.7be06d6d.davem@davemloft.net>
 <20041020225625.GD995@wotan.suse.de> <20041020160450.0914270b.davem@davemloft.net>
 <20041020232509.GF995@wotan.suse.de> <20041020164144.3457eafe.davem@davemloft.net>
In-Reply-To: <20041020164144.3457eafe.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>
Cc: Andi Kleen <ak@suse.de>, dhowells@redhat.com, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>, discuss@x86-64.org, sparclinux@vger.kernel.org, linuxppc64-dev@ozlabs.org, linux-m68k@vger.kernel.org, linux-sh@m17n.org, linux-arm-kernel@lists.arm.linux.org.uk, parisc-linux@parisc-linux.org, linux-ia64@vger.kernel.org, linux-390@vm.marist.edu, Linux/MIPS Development <linux-mips@linux-mips.org>

On Wed, 20 Oct 2004, David S. Miller wrote:
> On Thu, 21 Oct 2004 01:25:09 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > IMHO breaking the build unnecessarily is extremly bad because
> > it will prevent all testing. And would you really want to hold
> > up the whole linux testing machinery just for some obscure 
> > system call? IMHO not a good tradeoff.
> 
> Then change the unistd.h cookie from "#error" to a "#warning".  It
> accomplishes both of our goals.

Please do so! And not only for syscalls, but also for other things.

That way we can procmail all mails sent to lkml or bk-commits-head that
add #warnings to arch/<arch>/ or include/asm-<arch>/.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
