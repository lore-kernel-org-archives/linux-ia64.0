From: Al Viro <viro@zeniv.linux.org.uk>
Date: Tue, 15 Feb 2022 03:03:43 +0000
Subject: Re: [PATCH 14/14] uaccess: drop set_fs leftovers
Message-Id: <YgsYD2nW9GjWJtn5@zeniv-ca.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220214163452.1568807-1-arnd@kernel.org>
 <20220214163452.1568807-15-arnd@kernel.org>
In-Reply-To: <20220214163452.1568807-15-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, arnd@arndb.de, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, will@kernel.org, guoren@kernel.org, bcain@codeaurora.org, geert@linux-m68k.org, monstr@monstr.eu, tsbogend@alpha.franken.de, nickhu@andestech.com, green.hu@gmail.com, dinguyen@kernel.org, shorne@gmail.com, deller@gmx.de, mpe@ellerman.id.au, peterz@infradead.org, mingo@redhat.com, mark.rutland@arm.com, hca@linux.ibm.com, dalias@libc.org, davem@davemloft.net, richard@nod.at, x86@kernel.org, jcmvbkbc@gmail.com, ebiederm@xmission.com, akpm@linux-foundation.org, ardb@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org

On Mon, Feb 14, 2022 at 05:34:52PM +0100, Arnd Bergmann wrote:
> diff --git a/arch/parisc/include/asm/futex.h b/arch/parisc/include/asm/futex.h
> index b5835325d44b..2f4a1b1ef387 100644
> --- a/arch/parisc/include/asm/futex.h
> +++ b/arch/parisc/include/asm/futex.h
> @@ -99,7 +99,7 @@ futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr,
>  	/* futex.c wants to do a cmpxchg_inatomic on kernel NULL, which is
>  	 * our gateway page, and causes no end of trouble...
>  	 */
> -	if (uaccess_kernel() && !uaddr)
> +	if (!uaddr)
>  		return -EFAULT;

	Huh?  uaccess_kernel() is removed since it becomes always false now,
so this looks odd.

	AFAICS, the comment above that check refers to futex_detect_cmpxchg()
-> cmpxchg_futex_value_locked() -> futex_atomic_cmpxchg_inatomic() call chain.
Which had been gone since commit 3297481d688a (futex: Remove futex_cmpxchg
detection).  The comment *and* the check should've been killed off back
then.
	Let's make sure to get both now...
