From: Martin Pool <mbp@sourcefrog.net>
Date: Wed, 14 Apr 2004 06:22:28 +0000
Subject: Re: kernel update (relative to 2.6.5)
Message-Id: <pan.2004.04.14.06.22.27.138621@sourcefrog.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404140103.i3E13cB0004406@napali.hpl.hp.com>
In-Reply-To: <200404140103.i3E13cB0004406@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 13 Apr 2004 18:03:38 -0700, David Mosberger wrote:

> At long last, the ia64-patch for 2.6.5...
> It's in the usual place:
> 
>  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.6/
> 
> in file
> 
>  linux-2.6.5-ia64-040413.diff.gz

This seems to cause problems for me during make modules:

*** Warning: "per_cpu__local_per_cpu_offset" [drivers/net/yellowfin.ko] has no C                                                                                          RC!
*** Warning: "per_cpu__local_per_cpu_offset" [drivers/net/tulip/winbond-840.ko]                                                                                           has no CRC!
*** Warning: "per_cpu__local_per_cpu_offset" [drivers/net/via-rhine.ko] has no C                                                                                          RC!
*** Warning: "per_cpu__local_per_cpu_offset" [drivers/net/typhoon.ko] has no CRC                                                                                          !
*** Warning: "per_cpu__local_per_cpu_offset" [drivers/net/tulip/tulip.ko] has no                                                                                           CRC!
*** Warning: "per_cpu__local_per_cpu_offset" [drivers/net/tg3.ko] has no CRC!
*** Warning: "per_cpu__local_per_cpu_offset" [drivers/net/sundance.ko] has no CR                                                                                          C!
*** Warning: "per_cpu__local_per_cpu_offset" [drivers/net/starfire.ko] has no CR                                                                                          C!
*** Warning: "per_cpu__local_per_cpu_offset" [drivers/net/sk98lin/sk98lin.ko] ha                                                                                          s no CRC!

-- 
Martin

