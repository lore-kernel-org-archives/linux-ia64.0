From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 17 Aug 2004 01:10:24 +0000
Subject: Re: [PATCH] fix generic build when CONFIG_SMP=n
Message-Id: <200408161810.24682.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408131559.59229.jbarnes@engr.sgi.com>
In-Reply-To: <200408131559.59229.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sunday, August 15, 2004 8:29 pm, dann frazier wrote:
> On Fri, Aug 13, 2004 at 03:59:59PM -0700, Jesse Barnes wrote:
> > This patch fixes the issues I saw with CONFIG_SMP=n when building a
> > generic kernel with CONFIG_NUMA=y and CONFIG_DISCONTIGMEM=y.  It's still
> > pretty rough, but I'd appreciate comments and testing on other platforms.
> >  The per-cpu fixes are still pretty ugly--I'm sure I'm missing something
> > that would make abstracting out per_cpu(cpu_info, cpu).node_data > > mem_data[node].node_data much nicer looking.
> >
> > Fixing the build of generic kernels w/o CONFIG_NUMA or
> > CONFIG_DISCONTIGMEM is left as an exercise for the reader. :)
>
> Here's the results of some 2.6.8 boot testing:
>
> ---------------------------------------------------------------------------
>-- generic-no-smp-2    generic_defconfig
>     patch?                delta               machine           results
> ---------------------------------------------------------------------------
>-- No               ITANIUM=y                HP i2000            OK
> ---------------------------------------------------------------------------
>-- Yes              ITANIUM=y                HP i2000            OK
> ---------------------------------------------------------------------------
>-- Yes              ITANIUM=y                   N/A         build fails [1]
> SMP=n
> ---------------------------------------------------------------------------
>-- Yes              ITANIUM=y                   N/A         build fails [2]
> SMP=n
>                       CYCLONE=n
> ---------------------------------------------------------------------------
>-- Yes              ITANIUM=y                   N/A              OK SMP=n
>                       CYCLONE=n                HP i2000
>                       SERIAL_SGI_L1_CONSOLE=n
> ---------------------------------------------------------------------------
>-- Yes                                       HP rx2600           OK
> ---------------------------------------------------------------------------
>-- Yes              SMP=n                    HP rx2600           OK
> CYCLONE=n
>                       SERIAL_SGI_L1_CONSOLE=n

I posted fixes for cyclone and the sgi console driver separately.  They should 
get in soon.

Jesse
