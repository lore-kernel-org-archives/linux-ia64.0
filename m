From: Adrian Bunk <bunk@kernel.org>
Date: Mon, 14 Apr 2008 20:58:35 +0000
Subject: Re: [2.6 patch] add SGI_IOC4 hardware dependencies
Message-Id: <20080414205835.GG26885@cs181133002.pp.htv.fi>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080413181543.GF2182@cs181133002.pp.htv.fi>
In-Reply-To: <20080413181543.GF2182@cs181133002.pp.htv.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Apr 14, 2008 at 02:40:37PM -0500, Brent Casavant wrote:
> On Sun, 13 Apr 2008, Adrian Bunk wrote:
> 
> > Considering that all users of this code depend on
> > (IA64_SGI_SN2 || IA64_GENERIC) the SGI_IOC4 option
> > should also depend on it.
> > 
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> Tony,
> 
> Please don't apply this yet.  I'll need some guidance from Adrian
> and you on how to proceed.
> 
> The IOC4 chip _is_ available on a PCI card for x86 based systems.
> And that is why I removed the dependence of the config option on
> IA64_SGI_SN2 || IA64_GENERIC.
> 
> Unfortunately the only user of IOC4 on x86 is the "external interrupt"
> IOC4 sub-driver which is available under the GPL, but was not accepted
> into the Linux kernel.
>...

I wasn't aware of that driver.

Why wasn't it accepted?

> Brent

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

