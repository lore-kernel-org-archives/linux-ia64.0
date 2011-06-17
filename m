From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 17 Jun 2011 09:30:32 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary
Message-Id: <20110617093032.GA19235@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
In-Reply-To: <201106171038.25988.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org


* Petr Tesarik <ptesarik@suse.cz> wrote:

> This patch series enhances /dev/mem, so that read and write is 
> possible at any address. The patchset includes actual 
> implementation for x86.

This series lacks a description of why this is desired.

My strong opinion is that it's not desired at all: /dev/mem never 
worked beyond 4G addresses so by today it has become largely obsolete 
and is on the way out really.

I'm aware of these current /dev/mem uses:

 - Xorg maps below 4G non-RAM addresses and the video BIOS

 - It used to have some debugging role but these days kexec and kgdb 
   has largely taken over that role - partly due to the 4G limit.

 - there's some really horrible out-of-tree drivers that do mmap()s
   via /dev/mem, those should be fixed if they want to move beyond 
   4G: their char device should be mmap()able.

 - all distro kernel's i'm aware of use CONFIG_STRICT_DEVMEM=y, which
   restricts /dev/mem to non-RAM pages of physical memory.
   [ With the sad inclusion of the first 1MB, which Xorg needs. ]

Are you aware of any legitimate usecases?

Frankly, i dont think we ever *want* to 'fix' /dev/mem to support 
addresses beyond 4G and grow messy userspace (and kernelspace) that 
somehow relies on that. Thank goodness that we never supported it ...

Thanks,

	Ingo
