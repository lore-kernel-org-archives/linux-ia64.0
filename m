From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Wed, 13 Nov 2019 09:31:54 +0000
Subject: Re: [PATCH] video: fbdev: atyfb: only use ioremap_uc() on i386 and ia64
Message-Id: <20191113093154.GB32742@smile.fi.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191111192258.2234502-1-arnd@arndb.de>
 <20191112105507.GA7122@lst.de>
 <CAKMK7uEEz1n+zuTs29rbPHU74Dspaib=prpMge63L_-rUk_o4A@mail.gmail.com>
 <20191112140631.GA10922@lst.de>
 <CAKMK7uFaA607rOS6x_FWjXQ2+Qdm8dQ1dQ+Oi-9if_Qh_wHWPg@mail.gmail.com>
 <20191112222423.GO11244@42.do-not-panic.com>
 <20191113072708.GA3213@lst.de>
 <CAK8P3a3OpiWAep86tOiN1Fj2W7ud5hQ1OLTkBR8ueAKsMHk-dA@mail.gmail.com>
In-Reply-To: <CAK8P3a3OpiWAep86tOiN1Fj2W7ud5hQ1OLTkBR8ueAKsMHk-dA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Christoph Hellwig <hch@lst.de>, Luis Chamberlain <mcgrof@kernel.org>, Daniel Vetter <daniel.vetter@ffwll.ch>, Juergen Gross <jgross@suse.com>, Tuowen Zhao <ztuowen@gmail.com>, AceLan Kao <acelan.kao@canonical.com>, Mika Westerberg <mika.westerberg@linux.intel.com>, Roman Gilg <subdiff@gmail.com>, Lee Jones <lee.jones@linaro.org>, "Luis R. Rodriguez" <mcgrof@suse.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, dri-devel <dri-devel@lists.freedesktop.org>, Linux Fbdev development list <linux-fbdev@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Nov 13, 2019 at 08:38:15AM +0100, Arnd Bergmann wrote:
> On Wed, Nov 13, 2019 at 8:27 AM Christoph Hellwig <hch@lst.de> wrote:
> >
> > On Tue, Nov 12, 2019 at 10:24:23PM +0000, Luis Chamberlain wrote:
> > > I think this would be possible if we could flop ioremap_nocache() to UC
> > > instead of UC- on x86. Otherwise, I can't see how we can remove this by
> > > still not allowing direct MTRR calls.
> >
> > If everything goes well ioremap_nocache will be gone as of 5.5.
> 
> As ioremap_nocache() just an alias for ioremap(), I suppose the idea would
> then be to make x86 ioremap be UC instead of UC-, again matching what the
> other architectures do already.

I think it's right thing to do, i.e. assume that ioremap() always does strong
UC independently on MTRR settings.

-- 
With Best Regards,
Andy Shevchenko

