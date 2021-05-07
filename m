From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 07 May 2021 23:02:59 +0000
Subject: Re: [RFC 01/12] asm-generic: use asm-generic/unaligned.h for most architectures
Message-Id: <87czu2m9jw.ffs@nanos.tec.linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210507220813.365382-1-arnd@kernel.org> <20210507220813.365382-2-arnd@kernel.org>
In-Reply-To: <20210507220813.365382-2-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>, linux-arch@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Vineet Gupta <vgupta@synopsys.com>, Arnd Bergmann <arnd@arndb.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, "David S. Miller" <davem@davemloft.net>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-parisc@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org

On Sat, May 08 2021 at 00:07, Arnd Bergmann wrote:
> diff --git a/arch/x86/include/asm/unaligned.h b/arch/x86/include/asm/unaligned.h
> deleted file mode 100644
> index 9c754a7447aa..000000000000
> --- a/arch/x86/include/asm/unaligned.h
> +++ /dev/null
> @@ -1,15 +0,0 @@
> -/* SPDX-License-Identifier: GPL-2.0 */
> -#ifndef _ASM_X86_UNALIGNED_H
> -#define _ASM_X86_UNALIGNED_H
> -
> -/*
> - * The x86 can do unaligned accesses itself.
> - */
> -
> -#include <linux/unaligned/access_ok.h>
> -#include <linux/unaligned/generic.h>
> -
> -#define get_unaligned __get_unaligned_le
> -#define put_unaligned __put_unaligned_le
> -
> -#endif /* _ASM_X86_UNALIGNED_H */

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

Thanks for cleaning that up!

       tglx
