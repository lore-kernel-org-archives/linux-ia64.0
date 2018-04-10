From: James Hogan <jhogan@kernel.org>
Date: Tue, 10 Apr 2018 22:48:06 +0000
Subject: Re: [PATCH] bug.h: Work around GCC PR82365 in BUG()
Message-Id: <20180410224805.GA21429@saruman>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="sdtB3X0nJg68CQEu"
List-Id: <linux-ia64.vger.kernel.org>
References: <20171219114112.939391-1-arnd@arndb.de>
In-Reply-To: <20171219114112.939391-1-arnd@arndb.de>
To: Arnd Bergmann <arnd@arndb.de>, linux-mips@linux-mips.org, Paul Burton <paul.burton@mips.com>, Maciej Rozycki <macro@mips.com>
Cc: linux-arch@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, Vineet Gupta <vgupta@synopsys.com>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "David S. Miller" <davem@davemloft.net>, Christopher Li <sparse@chrisli.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Will Deacon <will.deacon@arm.com>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, Mark Rutland <mark.rutland@arm.com>, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m68k@vger.kernel.org, sparclinux@vger.kernel.org, linux-sparse@vger.kernel.org


--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Arnd,

On Tue, Dec 19, 2017 at 12:39:33PM +0100, Arnd Bergmann wrote:
> diff --git a/include/linux/compiler-gcc.h b/include/linux/compiler-gcc.h
> index 5d595cfdb2c4..66cfdad68f7e 100644
> --- a/include/linux/compiler-gcc.h
> +++ b/include/linux/compiler-gcc.h
> @@ -205,6 +205,15 @@
>  #endif
> =20
>  /*
> + * calling noreturn functions, __builtin_unreachable() and __builtin_tra=
p()
> + * confuse the stack allocation in gcc, leading to overly large stack
> + * frames, see https://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D82365
> + *
> + * Adding an empty inline assembly before it works around the problem
> + */
> +#define barrier_before_unreachable() asm volatile("")
> +
> +/*
>   * Mark a position in code as unreachable.  This can be used to
>   * suppress control flow warnings after asm blocks that transfer
>   * control elsewhere.
> @@ -214,7 +223,11 @@
>   * unreleased.  Really, we need to have autoconf for the kernel.
>   */
>  #define unreachable() \
> -	do { annotate_unreachable(); __builtin_unreachable(); } while (0)
> +	do {					\
> +		annotate_unreachable();		\
> +		barrier_before_unreachable();	\
> +		__builtin_unreachable();	\
> +	} while (0)

Unfortunately this breaks microMIPS builds (e.g. MIPS
micro32r2_defconfig and micro32r2el_defconfig) on gcc 7.2, due to the
lack of .insn in the asm volatile. Because of the
__builtin_unreachable() there is no code following it. Without the empty
asm the compiler will apparently put the .insn there automatically, but
with the empty asm it doesn't. Therefore the assembler won't treat an
immediately preceeding label as pointing at 16-bit microMIPS
instructions which need the ISA bit set, i.e. bit 0 of the address.
This causes assembler errors since the branch target is treated as a
different ISA mode:

arch/mips/mm/dma-default.s:3265: Error: branch to a symbol in another ISA m=
ode
arch/mips/mm/dma-default.s:5027: Error: branch to a symbol in another ISA m=
ode

Due to a compiler bug on gcc 4.9.2 -> somewhere before 7.2, Paul
submitted these patches a while back:
https://patchwork.linux-mips.org/patch/13360/
https://patchwork.linux-mips.org/patch/13361/

Your patch (suitably fixed for microMIPS) would I imagine fix that issue
too (it certainly fixes the resulting link error on microMIPS builds
with an old toolchain).

Before I forward port those patches to add .insn for MIPS, is that sort
of approach (an arch specific asm/compiler-gcc.h to allow MIPS to
override barrier_before_unreachable()) an acceptable fix?

Thanks
James

--sdtB3X0nJg68CQEu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEd80NauSabkiESfLYbAtpk944dnoFAlrNPx8ACgkQbAtpk944
dnqSJw/+Kb3O5v2XI2GmfHi/0KELq1a0ZD1AXtMeexXWCA/G67vblwP7DhFAB5px
IV666quqgKR09AdudWDm8+fMbH15AqlMBXRIgLRtyq6a8CuSD9P67MClnniB7+kq
hWOqGYKwg/jAmw5E/ALHs1Xl9CmNnLnyVVG+utwTO3vA/2BkeA81oSCaeokhKlOX
5KM9nTqjxW3eCP2syAXmlBli9bdGX7puZ3fXj7dNPbYTnOAT7E1NH4sD0+gr20Xv
Vjwn+JVKxCdyMrQqIG5E/enYM3Gk+4z9Xjv7GFQB/I/iOuhUBzHbm6Fy7B+08xhl
utcCYQKHnFia0a5rFHXesqonCB5KvATesX2yWYNpRatj/5Dn37kdY1+1hGqNeNbN
WNtXKVOegnWJnBLu7TQ8XJxZnYuKvA+2Uj2pb5tTD2M1SYqxAfsJdxqv9GnutJKH
R9INBc/U7/gqRfez9ycihU1ZcNJHj88I+ePMxUgphcKHdBiCryoO3Xf4+PA+EGhY
AW176RF4f7VgZP3WgJ3WOTfD4Cq+FfqKGcQDyD8KnZ7o0pdiRY1tcrczeyYLd7Rl
Rx7JcW9SE7SENMHbdiygBuLTKIbhYl1YXf9VcAm/mYSzgWfVhd9IXIN55FnViPvR
d3Z7bA8GuxlydlHGdt2OYgSuIuJ3+MqNpIhIOTBNASjd7PdEVAA=
=oUHg
-----END PGP SIGNATURE-----

--sdtB3X0nJg68CQEu--
