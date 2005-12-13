From: Adrian Bunk <bunk@stusta.de>
Date: Tue, 13 Dec 2005 18:51:50 +0000
Subject: Re: [2.6 patch] don't allow users to set CONFIG_BROKEN=y
Message-Id: <20051213185150.GP23349@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051211185212.GQ23349@stusta.de> <20051211192109.GA22537@flint.arm.linux.org.uk> <20051211193118.GR23349@stusta.de> <20051211194437.GB22537@flint.arm.linux.org.uk> <20051213001028.GS23349@stusta.de> <439ECDCC.80707@hogyros.de> <20051213140001.GG23349@stusta.de> <20051213173112.GA24094@flint.arm.linux.org.uk> <20051213180551.GN23349@stusta.de> <Pine.LNX.4.62.0512131926530.17990@pademelon.sonytel.be>
In-Reply-To: <Pine.LNX.4.62.0512131926530.17990@pademelon.sonytel.be>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Simon Richter <Simon.Richter@hogyros.de>, Linux Kernel Development <linux-kernel@vger.kernel.org>, tony.luck@intel.com, linux-ia64@vger.kernel.org, matthew@wil.cx, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, Paul Mackerras <paulus@samba.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, lethal@linux-sh.org, kkojima@rr.iij4u.or.jp, dwmw2@infradead.org, linux-mtd@lists.infradead.org

On Tue, Dec 13, 2005 at 07:28:41PM +0100, Geert Uytterhoeven wrote:
> On Tue, 13 Dec 2005, Adrian Bunk wrote:
> > Do not allow people to create configurations with CONFIG_BROKEN=y.
> > 
> > The sole reason for CONFIG_BROKEN=y would be if you are working on 
> > fixing a broken driver, but in this case editing the Kconfig file is 
> > trivial.
> > 
> > Never ever should a user enable CONFIG_BROKEN.
>                       ^^^^
> OK, a user, not an expert. Let's assume users don't enable EXPERIMENTAL.

Let's assume users don't have any hardware (e.g. several SATA drivers) 
that requires EXPERIMENTAL...

> But I'd like to at least have the possibility to enable broken drivers, even if
> it's just for compile regression tests.

If a kernel developer really wants to enable BROKEN drivers, my patch 
still gives them the possibility to do so with a trivial edit of
init/Kconfig.

> Gr{oetje,eeting}s,
> 
> 						Geert

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

