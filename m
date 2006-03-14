From: "Jun'ichi Nomura" <j-nomura@ce.jp.nec.com>
Date: Tue, 14 Mar 2006 23:55:55 +0000
Subject: Re: [PATCH] (-mm) drivers/pci/msi: explicit declaration of msi_register
Message-Id: <4417580B.2090205@ce.jp.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44172F0E.6070708@ce.jp.nec.com> <20060314215736.GV13973@stusta.de>
In-Reply-To: <20060314215736.GV13973@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@stusta.de>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Greg KH <gregkh@suse.de>, maule@sgi.com, Andrew Morton <akpm@osdl.org>

Adrian Bunk wrote:
>>include2/asm/msi.h: In function `ia64_msi_init':
>>include2/asm/msi.h:23: warning: implicit declaration of function `msi_register'
>>In file included from include2/asm/machvec.h:408,
>>                 from include2/asm/io.h:70,
>>                 from include2/asm/smp.h:20,
>>                 from /build/rc6/source/include/linux/smp.h:22,
>>...
> 
> To avoid any wrong impression:
> 
> This kind of warnings isn't harmless.
> 
> gcc tries to guess the prototype of the function, and if gcc guessed 
> wrong this can cause nasty and hard to debug runtime errors.

Sure.
But for this case, gcc emits the above warning for any files
which includes, for example, include/linux/smp.h on ia64.
So while the warning is harmless, it may cause other harmful
warnings being overlooked.

Thanks,
-- 
Jun'ichi Nomura, NEC Solutions (America), Inc.
