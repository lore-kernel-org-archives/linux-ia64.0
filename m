From: "Brian Cain" <bcain@codeaurora.org>
Date: Sat, 28 Mar 2020 02:48:38 +0000
Subject: RE: [PATCH 0/6] Kill setup_irq()
Message-Id: <059b01d604ab$637355b0$2a5a0110$@codeaurora.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200321174303.GA7930@afzalpc>
 <cover.1585320721.git.afzal.mohd.ma@gmail.com>
In-Reply-To: <cover.1585320721.git.afzal.mohd.ma@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'afzal mohammed' <afzal.mohd.ma@gmail.com>, 'Thomas Gleixner' <tglx@linutronix.de>
Cc: linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-alpha@vger.kernel.org, linux-omap@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

> -----Original Message-----
> From: linux-hexagon-owner@vger.kernel.org <linux-hexagon-
> owner@vger.kernel.org> On Behalf Of afzal mohammed
> Sent: Friday, March 27, 2020 11:08 AM
> To: Thomas Gleixner <tglx@linutronix.de>
> Cc: linux-kernel@vger.kernel.org; linux-arm-kernel@lists.infradead.org;
> linux-samsung-soc@vger.kernel.org; x86@kernel.org; linux-
> sh@vger.kernel.org; linux-s390@vger.kernel.org; linuxppc-
> dev@lists.ozlabs.org; linux-parisc@vger.kernel.org; linux-
> mips@vger.kernel.org; linux-m68k@lists.linux-m68k.org; linux-
> ia64@vger.kernel.org; linux-hexagon@vger.kernel.org; linux-c6x-dev@linux-
> c6x.org; linux-omap@vger.kernel.org; linux-alpha@vger.kernel.org
> Subject: [PATCH 0/6] Kill setup_irq()
...
> Note 1: sh toolchain is available, but that will not make the  relevant
changes
> compile as it has dependency of 64bit arch toolchain,  did try a Kconfig
hack
> to make it compile w/ 32bit sh toolchain, but it  failed due to other
reasons
> (unknown operands), so gave up on that.
> Note 2: hexagon final image creation fails even w/o my patch, but it  has
> been ensured that w/ my changes relevant object files are getting  built
w/o
> warnings.

Afzal,

	What's the nature of the failure in "Note 2"?

-Brian
