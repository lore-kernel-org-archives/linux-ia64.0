From: Adrian Bunk <bunk@stusta.de>
Date: Tue, 13 Dec 2005 00:10:28 +0000
Subject: Re: [2.6 patch] defconfig's shouldn't set CONFIG_BROKEN=y
Message-Id: <20051213001028.GS23349@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051211185212.GQ23349@stusta.de> <20051211192109.GA22537@flint.arm.linux.org.uk> <20051211193118.GR23349@stusta.de> <20051211194437.GB22537@flint.arm.linux.org.uk>
In-Reply-To: <20051211194437.GB22537@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, matthew@wil.cx, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, paulus@samba.org, linuxppc-dev@ozlabs.org, lethal@linux-sh.org, kkojima@rr.iij4u.or.jp, dwmw2@infradead.org, linux-mtd@lists.infradead.org

On Sun, Dec 11, 2005 at 07:44:37PM +0000, Russell King wrote:
> On Sun, Dec 11, 2005 at 08:31:18PM +0100, Adrian Bunk wrote:
> > On Sun, Dec 11, 2005 at 07:21:10PM +0000, Russell King wrote:
> > > On Sun, Dec 11, 2005 at 07:52:12PM +0100, Adrian Bunk wrote:
> > > > defconfig's shouldn't set CONFIG_BROKEN=y.
> > > 
> > > NACK.  This changes other configuration options in addition, for example
> > > in collie_defconfig:
> > > 
> > > -CONFIG_MTD_OBSOLETE_CHIPS=y
> > > -# CONFIG_MTD_AMDSTD is not set
> > > -CONFIG_MTD_SHARP=y
> > > -# CONFIG_MTD_JEDEC is not set
> > 
> > That's not a problem introduced by my patch.
> 
> It's a problem introduced by your patch because the resulting defconfig
> file becomes _wrong_ by your change, and other changes in the defconfig
> are thereby hidden.
>...


No, CONFIG_BROKEN=y in a defconfig file is a bug.

Either the defconfig doesn't use BROKEN code in which case it's simply 
wrong, or it's a wrong workaround (as in the CONFIG_MTD_SHARP case) for 
a wrong BROKEN dependency.


And it's a dangerous workaround:

Consider e.g. that "both marked as obsolete and BROKEN" are the best 
candidates for "remove obsolete code" cleanups - and there goes your 
driver to /dev/null ...


> Russell King

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

