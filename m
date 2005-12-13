From: Adrian Bunk <bunk@stusta.de>
Date: Tue, 13 Dec 2005 14:00:01 +0000
Subject: Re: [2.6 patch] defconfig's shouldn't set CONFIG_BROKEN=y
Message-Id: <20051213140001.GG23349@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051211185212.GQ23349@stusta.de> <20051211192109.GA22537@flint.arm.linux.org.uk> <20051211193118.GR23349@stusta.de> <20051211194437.GB22537@flint.arm.linux.org.uk> <20051213001028.GS23349@stusta.de> <439ECDCC.80707@hogyros.de>
In-Reply-To: <439ECDCC.80707@hogyros.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Richter <Simon.Richter@hogyros.de>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, matthew@wil.cx, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, paulus@samba.org, linuxppc-dev@ozlabs.org, lethal@linux-sh.org, kkojima@rr.iij4u.or.jp, dwmw2@infradead.org, linux-mtd@lists.infradead.org

On Tue, Dec 13, 2005 at 02:34:04PM +0100, Simon Richter wrote:

> Hi,

Hi Simon,

> Adrian Bunk wrote:
> 
> >>It's a problem introduced by your patch because the resulting defconfig
> >>file becomes _wrong_ by your change, and other changes in the defconfig
> >>are thereby hidden.
> >>...
> 
> >No, CONFIG_BROKEN=y in a defconfig file is a bug.
> 
> Indeed, but that's not the point. A defconfig file should be the result 
> of running one of the various configuration targets; yours are 
> hand-patched. If you run the defconfig target, it will copy the config 
> file and run oldconfig, thus resulting in a different configuration file 
> (because options may now be gone and hence disabled) than what was in 
> the defconfig, and thus people may come to the wrong conclusion that if 
> a driver is enabled in a defconfig file, it will be built.

defconfig files are virtually never a configuration for the kernel they 
are shipped with since they aren't updated every time some configuration 
option is changed.

Consider a defconfig with CONFIG_BROKEN=n, and a driver that is enabled 
in this defconfig gets for some reason marked as broken in the Kconfig 
file - this will give exactly the same result as the one you describe.

>    Simon

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

