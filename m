From: Adrian Bunk <bunk@stusta.de>
Date: Wed, 08 Feb 2006 01:19:38 +0000
Subject: Re: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <20060208011938.GJ3524@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060207231713.GG3524@stusta.de> <200602080052.k180qxg16788@unix-os.sc.intel.com>
In-Reply-To: <200602080052.k180qxg16788@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Keith Owens <kaos@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Feb 07, 2006 at 04:52:59PM -0800, Chen, Kenneth W wrote:
> Adrian Bunk wrote on Tuesday, February 07, 2006 3:17 PM
> > IOW, you want the patch below?
> > 
> 
> No, I really don't think so.
> 
> 
> > --- linux-2.6.16-rc1-mm5-ia64/arch/ia64/Kconfig.old
> > +++ linux-2.6.16-rc1-mm5-ia64/arch/ia64/Kconfig
> > @@ -132,10 +134,11 @@
> >  	  This choice is safe for all IA-64 systems, but may not perform
> >  	  optimally on systems with, say, Itanium 2 or newer processors.
> >  
> >  config MCKINLEY
> >  	bool "Itanium 2"
> > +	depends on IA64_GENERIC=n
> >  	help
> >  	  Select this to configure for an Itanium 2 (McKinley) processor.
> >  
> >  endchoice
> >  
> 
> This hunk does not make any logical sense.  Select generic system type
> does not mean Itanium processor is the only choice I can have.  What's
> wrong with having an option that works just fine right now?

You could ask the same question for NUMA:
Select generic system type does not mean NUMA systems are only choice I 
can have. What's wrong with having an option that works just fine?

Keith said IA64_GENERIC should select all the options required in order 
to run on all the IA64 platforms out there.
This is what my patch does.

> - Ken

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

