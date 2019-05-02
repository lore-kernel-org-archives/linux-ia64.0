From: Michael Ellerman <mpe@ellerman.id.au>
Date: Thu, 02 May 2019 15:31:10 +0000
Subject: Re: [PATCH] memblock: make keeping memblock memory opt-in rather than opt-out
Message-Id: <87h8acyitd.fsf@concordia.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556102150-32517-1-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1556102150-32517-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mips@vger.kernel.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-hexagon@vger.kernel.org, x86@kernel.org, Russell King <linux@armlinux.org.uk>, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Catalin Marinas <catalin.marinas@arm.com>, James Hogan <jhogan@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Will Deacon <will.deacon@arm.com>, linux-m68k@lists.linux-m68k.org, Borislav Petkov <bp@alien8.de>, nios2-dev@lists.rocketboards.org, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, Richard Kuo <rkuo@codeaurora.org>, Paul Burton <paul.burton@mips.com>, Eric Biederman <ebiederm@xmission.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Ley Foon Tan <lftan@altera.com>, linuxppc-dev@lists.ozlabs.org

Mike Rapoport <rppt@linux.ibm.com> writes:
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index 2d0be82..39877b9 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -143,6 +143,7 @@ config PPC
>  	select ARCH_HAS_UBSAN_SANITIZE_ALL
>  	select ARCH_HAS_ZONE_DEVICE		if PPC_BOOK3S_64
>  	select ARCH_HAVE_NMI_SAFE_CMPXCHG
> +	select ARCH_KEEP_MEMBLOCK

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers
