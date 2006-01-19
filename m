From: Adrian Bunk <bunk@stusta.de>
Date: Thu, 19 Jan 2006 16:09:44 +0000
Subject: Re: [2.6 patch] drivers/sn/ must be entered for CONFIG_SGI_IOC3
Message-Id: <20060119160944.GN19398@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060117235521.GA14298@redhat.com> <20060119032423.GI19398@stusta.de> <yq0vewg7dc7.fsf@jaguar.mkp.net>
In-Reply-To: <yq0vewg7dc7.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Dave Jones <davej@redhat.com>, pfg@sgi.com, Linux Kernel <linux-kernel@vger.kernel.org>, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Thu, Jan 19, 2006 at 04:54:00AM -0500, Jes Sorensen wrote:
> >>>>> "Adrian" = Adrian Bunk <bunk@stusta.de> writes:
> 
> Adrian> On Tue, Jan 17, 2006 at 06:55:21PM -0500, Dave Jones wrote:
> >> kernel/drivers/serial/ioc3_serial.ko needs unknown symbol
> >> ioc3_unregister_submodule
> >> 
> >> CONFIG_SERIAL_SGI_IOC3=m CONFIG_SGI_IOC3=m
> 
> Adrian> The untested patch below should fix it.
> 
> Actually I think this is more appropriate so we don't end up with 17
> cases that add drivers/sn to the build lib.
>...

I haven't tested your patch, but I agree that it's a better approach 
than my patch.
 
> Cheers,
> Jes
>...

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

