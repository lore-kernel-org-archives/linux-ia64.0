From: Linus Torvalds <torvalds@osdl.org>
Date: Wed, 06 Sep 2006 18:24:05 +0000
Subject: Re: [PATCH] IA64,sparc: local DoS with corrupted ELFs
Message-Id: <Pine.LNX.4.64.0609061120430.27779@g5.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <44FC193C.4080205@openvz.org>
In-Reply-To: <44FC193C.4080205@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kirill Korotaev <dev@openvz.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Fernando Vazquez <fernando@oss.ntt.co.jp>, "David S. Miller" <davem@davemloft.net>, tony.luck@intel.com, linux-ia64@vger.kernel.org, stable@kernel.org, xemul@openvz.org, devel@openvz.org



On Mon, 4 Sep 2006, Kirill Korotaev wrote:
> 
> this patch is already commited into -stable 2.6.17.y tree.

I don't like it. Apparently the patch was bad, and broken on MIPS and 
parisc, and it was applied to the stable tree without being in the 
standard tree.

If MIPS and parisc don't matter for the stable tree (very possible - there 
are no big commercial distributions for them), then dammit, neither should 
ia64 and sparc (there are no big commercial distros for them either). 
Either way, it seems this didn't happen the way it should have.

The proper fix would _seem_ to have the whole

	#ifndef arch_mmap_check
	#define arch_mmap_check(addr, len, flags) (0)
	#endif

in the only file that actually _uses_ this, namely mm/mmap.c. Rather than 
pollute lots of architecture-specific files with this macro that nobody 
really is interested in except for ia64 and sparc.

			Linus
