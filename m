From: Luis Chamberlain <mcgrof@kernel.org>
Date: Tue, 12 Nov 2019 22:17:44 +0000
Subject: Re: [PATCH] video: fbdev: atyfb: only use ioremap_uc() on i386 and ia64
Message-Id: <20191112221744.GN11244@42.do-not-panic.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191111192258.2234502-1-arnd@arndb.de>
 <20191112105507.GA7122@lst.de>
 <CAKMK7uEEz1n+zuTs29rbPHU74Dspaib=prpMge63L_-rUk_o4A@mail.gmail.com>
 <20191112140631.GA10922@lst.de>
In-Reply-To: <20191112140631.GA10922@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, Juergen Gross <jgross@suse.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Arnd Bergmann <arnd@arndb.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, dri-devel <dri-devel@lists.freedesktop.org>, Linux Fbdev development list <linux-fbdev@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tuowen Zhao <ztuowen@gmail.com>, Mika Westerberg <mika.westerberg@linux.intel.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>

On Tue, Nov 12, 2019 at 03:06:31PM +0100, Christoph Hellwig wrote:
> On Tue, Nov 12, 2019 at 02:04:16PM +0100, Daniel Vetter wrote:
> > Wut ... Maybe I'm missing something, but from how we use mtrr in other
> > gpu drivers it's a) either you use MTRR because that's all you got or
> > b) you use pat. Mixing both sounds like a pretty bad idea,

You misread the patch. And indeed there is a bit of complexity involved
here folks should be aware of as .. well, its been a while.

A mix of both MTRR and PAT is not effectively done on the code patch for
the atyb driver. If you have PAT only PAT is used.  If you don't have
PAT a solution is provided to use MTRR.

The goal of the patch really was to help finally avoid direct calls
to MTRR. *This* driver was the *one* crazy exception where we needed
to adddress this with a solution which would work effectively for both
non-PAT and PAT world which had crazy constraints.

So with this out of the way, no direct calls of MTRRs was possible and
there are future possible gains with this for x86. The biggest two were:

  1) Xen didn't have to implement MTRR hypervisor calls out for Linux
     guests. This means Xen guests don't have to enable MTRRs. Any code
     path avoiding such craziness as stop_machine() on each CPU during
     bootup, resume, CPU online and whenever an MTRR is set is a blessing.

  2) We may be closer in the future to getting ioremap_nocache to use
     UC isntead of UC-, this would be a win. x86 ioremap_nocache() does
     not use UC (strong UC), it just uses UC-.

Note though that BIOSes can *only* enable UC by using MTRR directly, fan
control for a system was one use case example that can come up, just as
an example. Ideally your BIOS won't need this. When and how this is done
is platform and BIOS specific though. So effectively, if a BIOS enables
MTRRs the Linux must keep them enabled. If the BIOS disables MTRRs the
kernel keeps them disabled.

> Can you take a look at "mfd: intel-lpss: Use devm_ioremap_uc for MMIO"
> in linux-next, which also looks rather fishy to me?  Can't we use
> the MTRR APIs to override the broken BIOS MTRR setup there as well?

The call there was put to allow precisely for such work around but also
allow the code to work on PAT / non-PAT systems by using the same API.

> With that we could kill ioremap_uc entirely.

ioremap_uc() is a compromise to avoid direct calls to MTRRs, since
ioremap_nocache() is not effectively yet using UC. Whether or not
other archs carry it.

  Luis
