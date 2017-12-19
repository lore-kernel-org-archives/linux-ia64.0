From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Date: Tue, 19 Dec 2017 16:57:10 +0000
Subject: Re: [PATCH] bug.h: Work around GCC PR82365 in BUG()
Message-Id: <8e42a1de-f619-7a4e-6d58-f90f53f5f38f@synopsys.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171219114112.939391-1-arnd@arndb.de>
In-Reply-To: <20171219114112.939391-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Arnd Bergmann <arnd@arndb.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>, Vineet Gupta <Vineet.Gupta1@synopsys.com>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "David S. Miller" <davem@davemloft.net>, Christopher Li <sparse@chrisli.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Will Deacon <will.deacon@arm.com>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, Mark Rutland <mark.rutland@arm.com>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-cris-kernel@axis.com" <linux-cris-kernel@axis.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-sparse@vger.kernel.org" <linux-sparse@vger.kernel.org>

On 12/19/2017 03:41 AM, Arnd Bergmann wrote:
> Looking at functions with large stack frames across all architectures
> led me discovering that BUG() suffers from the same problem as
> fortify_panic(), which I've added a workaround for already. In short,
> variables that go out of scope by calling a noreturn function or
> __builtin_unreachable() keep using stack space in functions afterwards.
>
> A workaround that was identified is to insert an empty assembler statement
> just before calling the function that doesn't return.  I'm adding a macro
> "barrier_before_unreachable()" to document this, and insert calls to
> that in all instances of BUG() that currently suffer from this problem.
>
> The files that saw the largest change from this had these frame sizes
> before, and much less with my patch:
>
> fs/ext4/inode.c:82:1: warning: the frame size of 1672 bytes is larger tha=
n 800 bytes [-Wframe-larger-than=3D]
> fs/ext4/namei.c:434:1: warning: the frame size of 904 bytes is larger tha=
n 800 bytes [-Wframe-larger-than=3D]
> fs/ext4/super.c:2279:1: warning: the frame size of 1160 bytes is larger t=
han 800 bytes [-Wframe-larger-than=3D]
> fs/ext4/xattr.c:146:1: warning: the frame size of 1168 bytes is larger th=
an 800 bytes [-Wframe-larger-than=3D]
> fs/f2fs/inode.c:152:1: warning: the frame size of 1424 bytes is larger th=
an 800 bytes [-Wframe-larger-than=3D]
> net/netfilter/ipvs/ip_vs_core.c:1195:1: warning: the frame size of 1068 b=
ytes is larger than 800 bytes [-Wframe-larger-than=3D]
> net/netfilter/ipvs/ip_vs_core.c:395:1: warning: the frame size of 1084 by=
tes is larger than 800 bytes [-Wframe-larger-than=3D]
> net/netfilter/ipvs/ip_vs_ftp.c:298:1: warning: the frame size of 928 byte=
s is larger than 800 bytes [-Wframe-larger-than=3D]
> net/netfilter/ipvs/ip_vs_ftp.c:418:1: warning: the frame size of 908 byte=
s is larger than 800 bytes [-Wframe-larger-than=3D]
> net/netfilter/ipvs/ip_vs_lblcr.c:718:1: warning: the frame size of 960 by=
tes is larger than 800 bytes [-Wframe-larger-than=3D]
> drivers/net/xen-netback/netback.c:1500:1: warning: the frame size of 1088=
 bytes is larger than 800 bytes [-Wframe-larger-than=3D]
>
> In case of ARC and CRIS, it turns out that the BUG() implementation
> actually does return (or at least the compiler thinks it does), resulting
> in lots of warnings about uninitialized variable use and leaving noreturn
> functions, such as:
>
> block/cfq-iosched.c: In function 'cfq_async_queue_prio':
> block/cfq-iosched.c:3804:1: error: control reaches end of non-void functi=
on [-Werror=3Dreturn-type]
> include/linux/dmaengine.h: In function 'dma_maxpq':
> include/linux/dmaengine.h:1123:1: error: control reaches end of non-void =
function [-Werror=3Dreturn-type]
>
> This makes them call __builtin_trap() instead, which should normally
> dump the stack and kill the current process, like some of the other
> architectures already do.
>
> I tried adding barrier_before_unreachable() to panic() and fortify_panic()
> as well, but that had very little effect, so I'm not submitting that
> patch.
>
> Link: https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__gcc.gnu.org_=
bugzilla_show-5Fbug.cgi-3Fid-3D82365&d=3DDwIBAg&c=3DDPL6_X_6JkXFx7AXWqB0tg&=
r=C14YS-cH-kdhTOW89KozFhBtBJgs1zXscZojEZQ0THs&m=3D3Iu4HWDn1cXkYBpSFh5I80IzD=
KJi33hs5DbfGM-b3mI&s=3DsTrcyN5ej_ION8hJvF9eGLUZYwdlwI50vXUp3MK-XWY&e> Signe=
d-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> The name barrier_before_unreachable() is a bit suboptimal here,
> as it fails to describe the fact that it is needed for both
> __builtin_unreachable() and for calling noreturn functions.  Any other
> suggestions would be welcome here.
> ---
>   arch/arc/include/asm/bug.h            |  3 ++-
>   arch/cris/include/arch-v10/arch/bug.h | 11 +++++++++--
>   arch/ia64/include/asm/bug.h           |  6 +++++-
>   arch/m68k/include/asm/bug.h           |  3 +++
>   arch/sparc/include/asm/bug.h          |  6 +++++-
>   include/asm-generic/bug.h             |  1 +
>   include/linux/compiler-gcc.h          | 15 ++++++++++++++-
>   include/linux/compiler.h              |  5 +++++
>   8 files changed, 44 insertions(+), 6 deletions(-)
>
> diff --git a/arch/arc/include/asm/bug.h b/arch/arc/include/asm/bug.h
> index ea022d47896c..21ec82466d62 100644
> --- a/arch/arc/include/asm/bug.h
> +++ b/arch/arc/include/asm/bug.h
> @@ -23,7 +23,8 @@ void die(const char *str, struct pt_regs *regs, unsigne=
d long address);
>  =20
>   #define BUG()	do {								\
>   	pr_warn("BUG: failure at %s:%d/%s()!\n", __FILE__, __LINE__, __func__)=
; \
> -	dump_stack();								\
> +	barrier_before_unreachable();						\
> +	__builtin_trap();							\
>   } while (0)
>  =20
>   #define HAVE_ARCH_BUG
> diff --git a/arch/cris/include/arch-v10/arch/bug.h b/arch/cris/include/ar=
ch-v10/arch/bug.h
> index 905afeacfedf..06da9d49152a 100644
> --- a/arch/cris/include/arch-v10/arch/bug.h
> +++ b/arch/cris/include/arch-v10/arch/bug.h
> @@ -44,18 +44,25 @@ struct bug_frame {
>    * not be used like this with newer versions of gcc.
>    */
>   #define BUG()								\
> +do {									\
>   	__asm__ __volatile__ ("clear.d [" __stringify(BUG_MAGIC) "]\n\t"\
>   			      "movu.w " __stringify(__LINE__) ",$r0\n\t"\
>   			      "jump 0f\n\t"				\
>   			      ".section .rodata\n"			\
>   			      "0:\t.string \"" __FILE__ "\"\n\t"	\
> -			      ".previous")
> +			      ".previous");				\
> +	unreachable();							\
> +} while (0)
>   #endif
>  =20
>   #else
>  =20
>   /* This just causes an oops. */
> -#define BUG() (*(int *)0 =3D 0)
> +#define BUG()								\
> +do {									\
> +	barrier_before_unreachable();					\
> +	__builtin_trap();						\

I suppose BUG() implies "dead end" like semantics - which ARC was lacking b=
efore ?

> +} while (0)
>  =20
>   #endif
>  =20
> diff --git a/arch/ia64/include/asm/bug.h b/arch/ia64/include/asm/bug.h
> index bd3eeb8d1cfa..66b37a532765 100644
> --- a/arch/ia64/include/asm/bug.h
> +++ b/arch/ia64/include/asm/bug.h
> @@ -4,7 +4,11 @@
>  =20
>   #ifdef CONFIG_BUG
>   #define ia64_abort()	__builtin_trap()
> -#define BUG() do { printk("kernel BUG at %s:%d!\n", __FILE__, __LINE__);=
 ia64_abort(); } while (0)
> +#define BUG() do {						\
> +	printk("kernel BUG at %s:%d!\n", __FILE__, __LINE__);	\
> +	barrier_before_unreachable();				\
> +	ia64_abort();						\
> +} while (0)
>  =20
>   /* should this BUG be made generic? */
>   #define HAVE_ARCH_BUG
> diff --git a/arch/m68k/include/asm/bug.h b/arch/m68k/include/asm/bug.h
> index b7e2bf1ba4a6..275dca1435bf 100644
> --- a/arch/m68k/include/asm/bug.h
> +++ b/arch/m68k/include/asm/bug.h
> @@ -8,16 +8,19 @@
>   #ifndef CONFIG_SUN3
>   #define BUG() do { \
>   	pr_crit("kernel BUG at %s:%d!\n", __FILE__, __LINE__); \
> +	barrier_before_unreachable(); \
>   	__builtin_trap(); \
>   } while (0)
>   #else
>   #define BUG() do { \
>   	pr_crit("kernel BUG at %s:%d!\n", __FILE__, __LINE__); \
> +	barrier_before_unreachable(); \
>   	panic("BUG!"); \
>   } while (0)
>   #endif
>   #else
>   #define BUG() do { \
> +	barrier_before_unreachable(); \
>   	__builtin_trap(); \
>   } while (0)
>   #endif
> diff --git a/arch/sparc/include/asm/bug.h b/arch/sparc/include/asm/bug.h
> index 6f17528356b2..ea53e418f6c0 100644
> --- a/arch/sparc/include/asm/bug.h
> +++ b/arch/sparc/include/asm/bug.h
> @@ -9,10 +9,14 @@
>   void do_BUG(const char *file, int line);
>   #define BUG() do {					\
>   	do_BUG(__FILE__, __LINE__);			\
> +	barrier_before_unreachable();			\
>   	__builtin_trap();				\
>   } while (0)
>   #else
> -#define BUG()		__builtin_trap()
> +#define BUG() do {					\
> +	barrier_before_unreachable();			\
> +	__builtin_trap();				\
> +} while (0)
>   #endif
>  =20
>   #define HAVE_ARCH_BUG
> diff --git a/include/asm-generic/bug.h b/include/asm-generic/bug.h
> index 963b755d19b0..a7613e1b0c87 100644
> --- a/include/asm-generic/bug.h
> +++ b/include/asm-generic/bug.h
> @@ -52,6 +52,7 @@ struct bug_entry {
>   #ifndef HAVE_ARCH_BUG
>   #define BUG() do { \
>   	printk("BUG: failure at %s:%d/%s()!\n", __FILE__, __LINE__, __func__);=
 \
> +	barrier_before_unreachable(); \
>   	panic("BUG!"); \
>   } while (0)
>   #endif
> diff --git a/include/linux/compiler-gcc.h b/include/linux/compiler-gcc.h
> index 5d595cfdb2c4..66cfdad68f7e 100644
> --- a/include/linux/compiler-gcc.h
> +++ b/include/linux/compiler-gcc.h
> @@ -205,6 +205,15 @@
>   #endif
>  =20
>   /*
> + * calling noreturn functions, __builtin_unreachable() and __builtin_tra=
p()
> + * confuse the stack allocation in gcc, leading to overly large stack
> + * frames, see https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__gc=
c.gnu.org_bugzilla_show-5Fbug.cgi-3Fid-3D82365&d=3DDwIBAg&c=3DDPL6_X_6JkXFx=
7AXWqB0tg&r=C14YS-cH-kdhTOW89KozFhBtBJgs1zXscZojEZQ0THs&m=3D3Iu4HWDn1cXkYBp=
SFh5I80IzDKJi33hs5DbfGM-b3mI&s=3DsTrcyN5ej_ION8hJvF9eGLUZYwdlwI50vXUp3MK-XW=
Y&e> + *
> + * Adding an empty inline assembly before it works around the problem
> + */
> +#define barrier_before_unreachable() asm volatile("")
> +
> +/*
>    * Mark a position in code as unreachable.  This can be used to
>    * suppress control flow warnings after asm blocks that transfer
>    * control elsewhere.
> @@ -214,7 +223,11 @@
>    * unreleased.  Really, we need to have autoconf for the kernel.
>    */
>   #define unreachable() \
> -	do { annotate_unreachable(); __builtin_unreachable(); } while (0)
> +	do {					\
> +		annotate_unreachable();		\
> +		barrier_before_unreachable();	\
> +		__builtin_unreachable();	\
> +	} while (0)
>  =20
>   /* Mark a function definition as prohibited from being cloned. */
>   #define __noclone	__attribute__((__noclone__, __optimize__("no-tracer")=
))
> diff --git a/include/linux/compiler.h b/include/linux/compiler.h
> index 52e611ab9a6c..97847f2f86cf 100644
> --- a/include/linux/compiler.h
> +++ b/include/linux/compiler.h
> @@ -86,6 +86,11 @@ void ftrace_likely_update(struct ftrace_likely_data *f=
, int val,
>   # define barrier_data(ptr) barrier()
>   #endif
>  =20
> +/* workaround for GCC PR82365 if needed */
> +#ifndef barrier_before_unreachable
> +# define barrier_before_unreachable() do { } while (0)
> +#endif
> +
>   /* Unreachable code */
>   #ifdef CONFIG_STACK_VALIDATION
>   /*

