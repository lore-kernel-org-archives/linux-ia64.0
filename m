From: Adrian Bunk <bunk@stusta.de>
Date: Tue, 14 Mar 2006 21:57:36 +0000
Subject: Re: [PATCH] (-mm) drivers/pci/msi: explicit declaration of msi_register
Message-Id: <20060314215736.GV13973@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <44172F0E.6070708@ce.jp.nec.com>
In-Reply-To: <44172F0E.6070708@ce.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Greg KH <gregkh@suse.de>, maule@sgi.com, Andrew Morton <akpm@osdl.org>

On Tue, Mar 14, 2006 at 04:01:02PM -0500, Jun'ichi Nomura wrote:
> Hello,
> 
> In 2.6.16-rc6-mm1, I've seen tons of compiler warnings on ia64:
> 
> include2/asm/msi.h: In function `ia64_msi_init':
> include2/asm/msi.h:23: warning: implicit declaration of function `msi_register'
> In file included from include2/asm/machvec.h:408,
>                  from include2/asm/io.h:70,
>                  from include2/asm/smp.h:20,
>                  from /build/rc6/source/include/linux/smp.h:22,
> 
> The problem is that msi_register() is used in ia64_msi_init()
> without declaration.
> Since ia64_msi_init() is a part of machine vector, most of files
> hit this warning and may hide other important messages.
>...

To avoid any wrong impression:

This kind of warnings isn't harmless.

gcc tries to guess the prototype of the function, and if gcc guessed 
wrong this can cause nasty and hard to debug runtime errors.

> Thanks,
>...

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

