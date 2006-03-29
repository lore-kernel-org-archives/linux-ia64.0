From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Wed, 29 Mar 2006 16:59:07 +0000
Subject: Re: gate.S and recent toolchains
Message-Id: <200603291659.k2TGx7dM1996881@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB0DE.1040409@sgi.com>
In-Reply-To: <442AB0DE.1040409@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:
> 
> Hi,
> 
> I've been chasing a very strange but since Monday and I am starting
> to hit a brick wall.
> 
> Basically I am unable to build a kernel from Linus' git tree on one
> system since Monday morning, whereas it boots fine if I build it on an
> older system. I tried installing an older toolchain on this box but it
> still didn't seem to make a difference. The system boots, calls init and
> I most often get the message "INIT: 2.85 booting", then a hang. In some

My kernel says "INIT: version 2.86 booting" and works.

> instances I don't even get the INIT message.
> 
> What sparked it was Russ Anderson's patch which added a few lines to
> include/asm-ia64/asmmacros.h, git id
> d2a28ad9fa7bf16761d070d8a3338375e1574b32
> 
> I've tracked it down to being the two lines doing a .section/.previous
> in the below patch chunk causing it. However it doesn't seem to be the
> specific .section name that does it, ie. any random .section/.previous
> pair I add to arch/ia64/kernel/gate.S has the same effect.
> 
> Now I am not a wiz in linker/gas magic, so I was hoping someone else
> had an idea what could be causing this? Anyone seen anything similar?
> 
> The specific toolchain I am using is gcc-4.1.0 based, but I tried
> 3.3.4 (with binutils 2.15) and it failed as well. However 4.0.2 on
> another system seems to do fine (admittedly it had binutils 2.14.90.x).
> 
> Any suggestions would be greatly appreciated.
> 
> Thanks,
> Jes
> 
> 
> 
> diff --git a/include/asm-ia64/asmmacro.h b/include/asm-ia64/asmmacro.h
> index 77af457..d4cec32 100644
> --- a/include/asm-ia64/asmmacro.h
> +++ b/include/asm-ia64/asmmacro.h
> @@ -51,6 +51,17 @@ name:
>    [99:]        x
> 
>  /*
> + * Tag MCA recoverable instruction ranges.
> + */
> +
> +       .section "__mca_table", "a"             // declare section &
> section attributes
> +       .previous
> +
> +# define MCA_RECOVER_RANGE(y)                  \
> +       .xdata4 "__mca_table", y-., 99f-.;      \
> +  [99:]
> +
> +/*
>   * Mark instructions that need a load of a virtual address patched to be
>   * a load of a physical address.  We use this either in critical
> performance
>   * path (ivt.S - TLB miss processing) or in places where it might not be
> 


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
