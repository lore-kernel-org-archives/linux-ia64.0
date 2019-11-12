From: Christoph Hellwig <hch@lst.de>
Date: Tue, 12 Nov 2019 14:06:31 +0000
Subject: Re: [PATCH] video: fbdev: atyfb: only use ioremap_uc() on i386 and ia64
Message-Id: <20191112140631.GA10922@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191111192258.2234502-1-arnd@arndb.de> <20191112105507.GA7122@lst.de> <CAKMK7uEEz1n+zuTs29rbPHU74Dspaib=prpMge63L_-rUk_o4A@mail.gmail.com>
In-Reply-To: <CAKMK7uEEz1n+zuTs29rbPHU74Dspaib=prpMge63L_-rUk_o4A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, dri-devel <dri-devel@lists.freedesktop.org>, Linux Fbdev development list <linux-fbdev@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Luis Chamberlain <mcgrof@kernel.org>, Tuowen Zhao <ztuowen@gmail.com>, Mika Westerberg <mika.westerberg@linux.intel.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>

On Tue, Nov 12, 2019 at 02:04:16PM +0100, Daniel Vetter wrote:
> Wut ... Maybe I'm missing something, but from how we use mtrr in other
> gpu drivers it's a) either you use MTRR because that's all you got or
> b) you use pat. Mixing both sounds like a pretty bad idea, since if
> you need MTRR for performance (because you dont have PAT) then you
> can't fix the wc with the PAT-based ioremap_uc. And if you have PAT,
> then you don't really need an MTRR to get wc.
> 
> So I'd revert this patch from Luis and ...

Sounds great to me..

> ... apply this one. Since the same reasoning should apply to anything
> that's running on any cpu with PAT.

Can you take a look at "mfd: intel-lpss: Use devm_ioremap_uc for MMIO"
in linux-next, which also looks rather fishy to me?  Can't we use
the MTRR APIs to override the broken BIOS MTRR setup there as well?

With that we could kill ioremap_uc entirely.
