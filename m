From: Max Filippov <jcmvbkbc@gmail.com>
Date: Tue, 22 Feb 2022 12:49:44 +0000
Subject: Re: [PATCH 2/2] xtensa: termbits.h is identical to asm-generic one
Message-Id: <CAMo8BfKHn4MAwP++EgvB1ZNB7=qwydi-FZB_hrcjamP4pj01xg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220222115604.7351-1-ilpo.jarvinen@linux.intel.com> <20220222115604.7351-3-ilpo.jarvinen@linux.intel.com>
In-Reply-To: <20220222115604.7351-3-ilpo.jarvinen@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: =?UTF-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@linux.intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jirislaby@kernel.org>, linux-serial@vger.kernel.org, "open list:IA64 (Itanium) PL..." <linux-ia64@vger.kernel.org>, Chris Zankel <chris@zankel.net>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>

On Tue, Feb 22, 2022 at 3:56 AM Ilpo Järvinen
<ilpo.jarvinen@linux.intel.com> wrote:
>
> Remove arch specific termbits.h as there are only trivial space
> differences between include/uapi/asm-generic/termbits.h and
> arch/xtensa/include/uapi/asm/termbits.h.
>
> $ diff -u0 -b -B include/uapi/asm-generic/termbits.h arch/xtensa/include/uapi/asm/termbits.h
> . --- include/uapi/asm-generic/termbits.h       2022-01-10 13:44:42.814107461 +0200
> . +++ arch/xtensa/include/uapi/asm/termbits.h   2022-01-10 13:44:42.690106926 +0200
> . @@ -2,2 +2,15 @@
> . -#ifndef __ASM_GENERIC_TERMBITS_H
> . -#define __ASM_GENERIC_TERMBITS_H
> . +/*
> . + * include/asm-xtensa/termbits.h
> . + *
> . + * Copied from SH.
> . + *
> . + * This file is subject to the terms and conditions of the GNU General Public
> . + * License.  See the file "COPYING" in the main directory of this archive
> . + * for more details.
> . + *
> . + * Copyright (C) 2001 - 2005 Tensilica Inc.
> . + */
> . +
> . +#ifndef _XTENSA_TERMBITS_H
> . +#define _XTENSA_TERMBITS_H
> . +
> . @@ -200 +221 @@
> . -#endif /* __ASM_GENERIC_TERMBITS_H */
> . +#endif /* _XTENSA_TERMBITS_H */
>
> Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@linux.intel.com>
> Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>  arch/xtensa/include/uapi/asm/termbits.h | 221 ------------------------
>  1 file changed, 221 deletions(-)
>  delete mode 100644 arch/xtensa/include/uapi/asm/termbits.h

Acked-by: Max Filippov <jcmvbkbc@gmail.com>

-- 
Thanks.
-- Max
