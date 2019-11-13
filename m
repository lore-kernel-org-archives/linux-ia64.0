From: Christoph Hellwig <hch@lst.de>
Date: Wed, 13 Nov 2019 07:27:08 +0000
Subject: Re: [PATCH] video: fbdev: atyfb: only use ioremap_uc() on i386 and ia64
Message-Id: <20191113072708.GA3213@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191111192258.2234502-1-arnd@arndb.de> <20191112105507.GA7122@lst.de> <CAKMK7uEEz1n+zuTs29rbPHU74Dspaib=prpMge63L_-rUk_o4A@mail.gmail.com> <20191112140631.GA10922@lst.de> <CAKMK7uFaA607rOS6x_FWjXQ2+Qdm8dQ1dQ+Oi-9if_Qh_wHWPg@mail.gmail.com> <20191112222423.GO11244@42.do-not-panic.com>
In-Reply-To: <20191112222423.GO11244@42.do-not-panic.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luis Chamberlain <mcgrof@kernel.org>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Juergen Gross <jgross@suse.com>, Christoph Hellwig <hch@lst.de>, Tuowen Zhao <ztuowen@gmail.com>, AceLan Kao <acelan.kao@canonical.com>, Mika Westerberg <mika.westerberg@linux.intel.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Roman Gilg <subdiff@gmail.com>, Lee Jones <lee.jones@linaro.org>, "Luis R. Rodriguez" <mcgrof@suse.com>, Arnd Bergmann <arnd@arndb.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, dri-devel <dri-devel@lists.freedesktop.org>, Linux Fbdev development list <linux-fbdev@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Nov 12, 2019 at 10:24:23PM +0000, Luis Chamberlain wrote:
> I think this would be possible if we could flop ioremap_nocache() to UC
> instead of UC- on x86. Otherwise, I can't see how we can remove this by
> still not allowing direct MTRR calls.

If everything goes well ioremap_nocache will be gone as of 5.5.
