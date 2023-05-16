From: "Maciej W. Rozycki" <macro@orcam.me.uk>
Date: Tue, 16 May 2023 00:53:45 +0000
Subject: Re: [PATCH v5 14/26] alpha: Remove empty <uapi/asm/setup.h>
Message-Id: <alpine.DEB.2.21.2305160147100.11892@angie.orcam.me.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230306100508.1171812-1-alexghiti@rivosinc.com> <20230306100508.1171812-15-alexghiti@rivosinc.com>
In-Reply-To: <20230306100508.1171812-15-alexghiti@rivosinc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexandre Ghiti <alexghiti@rivosinc.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, Jonathan Corbet <corbet@lwn.net>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Palmer Dabbelt <palmer@rivosinc.com>

On Mon, 6 Mar 2023, Alexandre Ghiti wrote:

> diff --git a/arch/alpha/include/uapi/asm/setup.h b/arch/alpha/include/uapi/asm/setup.h
> deleted file mode 100644
> index 9b3b5ba39b1d..000000000000
> --- a/arch/alpha/include/uapi/asm/setup.h
> +++ /dev/null
> @@ -1,5 +0,0 @@
> -/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
> -#ifndef _UAPI__ALPHA_SETUP_H
> -#define _UAPI__ALPHA_SETUP_H
> -
> -#endif /* _UAPI__ALPHA_SETUP_H */

 You can't just remove a UAPI header like this, something will break; cf. 
arch/arc/include/uapi/asm/setup.h, or arch/x86/include/uapi/asm/setup.h if 
you want it brief.

 I suggest that you fold it into 01/26 (it makes no sense to have empty 
multiple inclusion protection), and likewise for the relevant remaining 
headers.

  Maciej
