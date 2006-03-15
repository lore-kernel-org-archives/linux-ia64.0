From: Mark Maule <maule@sgi.com>
Date: Wed, 15 Mar 2006 00:09:23 +0000
Subject: Re: [PATCH] (-mm) drivers/pci/msi: explicit declaration of msi_register
Message-Id: <20060315000923.GC25848@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44172F0E.6070708@ce.jp.nec.com> <20060314215736.GV13973@stusta.de> <4417580B.2090205@ce.jp.nec.com>
In-Reply-To: <4417580B.2090205@ce.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Cc: Adrian Bunk <bunk@stusta.de>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Greg KH <gregkh@suse.de>, Andrew Morton <akpm@osdl.org>

On Tue, Mar 14, 2006 at 06:55:55PM -0500, Jun'ichi Nomura wrote:
> Adrian Bunk wrote:
> >>include2/asm/msi.h: In function `ia64_msi_init':
> >>include2/asm/msi.h:23: warning: implicit declaration of function 
> >>`msi_register'
> >>In file included from include2/asm/machvec.h:408,
> >>                from include2/asm/io.h:70,
> >>                from include2/asm/smp.h:20,
> >>                from /build/rc6/source/include/linux/smp.h:22,
> >>...
> >
> >To avoid any wrong impression:
> >
> >This kind of warnings isn't harmless.
> >
> >gcc tries to guess the prototype of the function, and if gcc guessed 
> >wrong this can cause nasty and hard to debug runtime errors.
> 
> Sure.
> But for this case, gcc emits the above warning for any files
> which includes, for example, include/linux/smp.h on ia64.
> So while the warning is harmless, it may cause other harmful
> warnings being overlooked.
> 

Yes, this should be cleaned up.  I'll take a look.

I thought though that we had all of this compiling cleanly ... guess not.

Mark
