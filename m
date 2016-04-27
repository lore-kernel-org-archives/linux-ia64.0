From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Date: Wed, 27 Apr 2016 08:41:31 +0000
Subject: Re: [PATCH 3/8] char/rtc: remove empty asm/mc146818rtc.h files
Message-Id: <20160427084131.GH3264@piout.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461707052-1337718-1-git-send-email-arnd@arndb.de>
 <1461707052-1337718-4-git-send-email-arnd@arndb.de>
In-Reply-To: <1461707052-1337718-4-git-send-email-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, tony.luck@intel.com, geert@linux-m68k.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, mpe@ellerman.id.au, dalias@libc.org, dhowells@redhat.com, yasutake.koichi@jp.panasonic.com, rth@twiddle.net, ink@jurassic.park.msu.ru, linux-alpha@vger.kernel.org, x86@kernel.org, a.zummo@towertech.it, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, rtc-linux@googlegroups.com, linux-arch@vger.kernel.org

On 26/04/2016 at 23:44:07 +0200, Arnd Bergmann wrote :
> Nothing on these architectures ever includes the asm/mc146818rtc.h
> file, the drivers that used to do this have been fixed long ago,
> and the remaining users are all PC-specific.
> 
> This removes the files for good.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>

> ---
>  arch/frv/include/asm/mc146818rtc.h    | 16 ----------------
>  arch/h8300/include/asm/mc146818rtc.h  |  9 ---------
>  arch/ia64/include/asm/mc146818rtc.h   | 10 ----------
>  arch/parisc/include/asm/mc146818rtc.h |  9 ---------
>  arch/sh/include/asm/mc146818rtc.h     |  7 -------
>  5 files changed, 51 deletions(-)
>  delete mode 100644 arch/frv/include/asm/mc146818rtc.h
>  delete mode 100644 arch/h8300/include/asm/mc146818rtc.h
>  delete mode 100644 arch/ia64/include/asm/mc146818rtc.h
>  delete mode 100644 arch/parisc/include/asm/mc146818rtc.h
>  delete mode 100644 arch/sh/include/asm/mc146818rtc.h
> 
> diff --git a/arch/frv/include/asm/mc146818rtc.h b/arch/frv/include/asm/mc146818rtc.h
> deleted file mode 100644
> index 90dfb7a633d1..000000000000
> --- a/arch/frv/include/asm/mc146818rtc.h
> +++ /dev/null
> @@ -1,16 +0,0 @@
> -/* mc146818rtc.h: RTC defs
> - *
> - * Copyright (C) 2005 Red Hat, Inc. All Rights Reserved.
> - * Written by David Howells (dhowells@redhat.com)
> - *
> - * This program is free software; you can redistribute it and/or
> - * modify it under the terms of the GNU General Public License
> - * as published by the Free Software Foundation; either version
> - * 2 of the License, or (at your option) any later version.
> - */
> -
> -#ifndef _ASM_MC146818RTC_H
> -#define _ASM_MC146818RTC_H
> -
> -
> -#endif /* _ASM_MC146818RTC_H */
> diff --git a/arch/h8300/include/asm/mc146818rtc.h b/arch/h8300/include/asm/mc146818rtc.h
> deleted file mode 100644
> index ab9d9646d241..000000000000
> --- a/arch/h8300/include/asm/mc146818rtc.h
> +++ /dev/null
> @@ -1,9 +0,0 @@
> -/*
> - * Machine dependent access functions for RTC registers.
> - */
> -#ifndef _H8300_MC146818RTC_H
> -#define _H8300_MC146818RTC_H
> -
> -/* empty include file to satisfy the include in genrtc.c/ide-geometry.c */
> -
> -#endif /* _H8300_MC146818RTC_H */
> diff --git a/arch/ia64/include/asm/mc146818rtc.h b/arch/ia64/include/asm/mc146818rtc.h
> deleted file mode 100644
> index 407787a237ba..000000000000
> --- a/arch/ia64/include/asm/mc146818rtc.h
> +++ /dev/null
> @@ -1,10 +0,0 @@
> -#ifndef _ASM_IA64_MC146818RTC_H
> -#define _ASM_IA64_MC146818RTC_H
> -
> -/*
> - * Machine dependent access functions for RTC registers.
> - */
> -
> -/* empty include file to satisfy the include in genrtc.c */
> -
> -#endif /* _ASM_IA64_MC146818RTC_H */
> diff --git a/arch/parisc/include/asm/mc146818rtc.h b/arch/parisc/include/asm/mc146818rtc.h
> deleted file mode 100644
> index adf41631449f..000000000000
> --- a/arch/parisc/include/asm/mc146818rtc.h
> +++ /dev/null
> @@ -1,9 +0,0 @@
> -/*
> - * Machine dependent access functions for RTC registers.
> - */
> -#ifndef _ASM_MC146818RTC_H
> -#define _ASM_MC146818RTC_H
> -
> -/* empty include file to satisfy the include in genrtc.c */
> -
> -#endif /* _ASM_MC146818RTC_H */
> diff --git a/arch/sh/include/asm/mc146818rtc.h b/arch/sh/include/asm/mc146818rtc.h
> deleted file mode 100644
> index 0aee96a97330..000000000000
> --- a/arch/sh/include/asm/mc146818rtc.h
> +++ /dev/null
> @@ -1,7 +0,0 @@
> -/*
> - * Machine dependent access functions for RTC registers.
> - */
> -#ifndef _ASM_MC146818RTC_H
> -#define _ASM_MC146818RTC_H
> -
> -#endif /* _ASM_MC146818RTC_H */
> -- 
> 2.7.0
> 

-- 
Alexandre Belloni, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
