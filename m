From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Tue, 12 Nov 2019 14:26:35 +0000
Subject: Re: [PATCH] video: fbdev: atyfb: only use ioremap_uc() on i386 and ia64
Message-Id: <CAKMK7uFaA607rOS6x_FWjXQ2+Qdm8dQ1dQ+Oi-9if_Qh_wHWPg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191111192258.2234502-1-arnd@arndb.de> <20191112105507.GA7122@lst.de>
 <CAKMK7uEEz1n+zuTs29rbPHU74Dspaib=prpMge63L_-rUk_o4A@mail.gmail.com> <20191112140631.GA10922@lst.de>
In-Reply-To: <20191112140631.GA10922@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, Tuowen Zhao <ztuowen@gmail.com>, AceLan Kao <acelan.kao@canonical.com>, Mika Westerberg <mika.westerberg@linux.intel.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Roman Gilg <subdiff@gmail.com>, Lee Jones <lee.jones@linaro.org>, "Luis R. Rodriguez" <mcgrof@suse.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, dri-devel <dri-devel@lists.freedesktop.org>, Linux Fbdev development list <linux-fbdev@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Luis Chamberlain <mcgrof@kernel.org>

On Tue, Nov 12, 2019 at 3:06 PM Christoph Hellwig <hch@lst.de> wrote:
> On Tue, Nov 12, 2019 at 02:04:16PM +0100, Daniel Vetter wrote:
> > Wut ... Maybe I'm missing something, but from how we use mtrr in other
> > gpu drivers it's a) either you use MTRR because that's all you got or
> > b) you use pat. Mixing both sounds like a pretty bad idea, since if
> > you need MTRR for performance (because you dont have PAT) then you
> > can't fix the wc with the PAT-based ioremap_uc. And if you have PAT,
> > then you don't really need an MTRR to get wc.
> >
> > So I'd revert this patch from Luis and ...
>
> Sounds great to me..
>
> > ... apply this one. Since the same reasoning should apply to anything
> > that's running on any cpu with PAT.
>
> Can you take a look at "mfd: intel-lpss: Use devm_ioremap_uc for MMIO"
> in linux-next, which also looks rather fishy to me?  Can't we use
> the MTRR APIs to override the broken BIOS MTRR setup there as well?

Hm so that's way out of my knowledge, but I think mtrr_cleanup() was
supposed to fix up messy/broken MTRR setups by the bios. So maybe they
simply didn't enable that in their .config with CONFIG_MTRR_SANITIZER.

An explicit cleanup is currently not possible for drivers, since the
only interface exported to drivers is arch_phys_wc_add/del (which
short-circuits if pat works since you don't need mtrr in that case).
Adding everyone from that commit, plus Luis. Drivers really shouldn't
assume/work around the bios setting up superflous/wrong MTRR.

> With that we could kill ioremap_uc entirely.

So yeah removing that seems definitely like the right thing.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch
