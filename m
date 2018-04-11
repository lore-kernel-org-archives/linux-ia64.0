From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 11 Apr 2018 07:30:56 +0000
Subject: Re: [PATCH] bug.h: Work around GCC PR82365 in BUG()
Message-Id: <CAK8P3a0-_u7_FCj-nH0izBv4ub6krm1uA32bwi2jtBzXJePcnQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171219114112.939391-1-arnd@arndb.de> <20180410224805.GA21429@saruman>
In-Reply-To: <20180410224805.GA21429@saruman>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: James Hogan <jhogan@kernel.org>
Cc: "open list:RALINK MIPS ARCHITECTURE" <linux-mips@linux-mips.org>, Paul Burton <paul.burton@mips.com>, Maciej Rozycki <macro@mips.com>, linux-arch <linux-arch@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Vineet Gupta <vgupta@synopsys.com>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "David S. Miller" <davem@davemloft.net>, Christopher Li <sparse@chrisli.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Will Deacon <will.deacon@arm.com>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, Mark Rutland <mark.rutland@arm.com>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m68k@vger.kernel.org, sparclinux <sparclinux@vger.kernel.org>, linux-sparse@vger.kernel.org

On Wed, Apr 11, 2018 at 12:48 AM, James Hogan <jhogan@kernel.org> wrote:
> Hi Arnd,
>
> On Tue, Dec 19, 2017 at 12:39:33PM +0100, Arnd Bergmann wrote:
>> diff --git a/include/linux/compiler-gcc.h b/include/linux/compiler-gcc.h
>> index 5d595cfdb2c4..66cfdad68f7e 100644
>> --- a/include/linux/compiler-gcc.h
>> +++ b/include/linux/compiler-gcc.h
>> @@ -205,6 +205,15 @@
>>  #endif
>>
>>  /*
>> + * calling noreturn functions, __builtin_unreachable() and __builtin_tr=
ap()
>> + * confuse the stack allocation in gcc, leading to overly large stack
>> + * frames, see https://gcc.gnu.org/bugzilla/show_bug.cgi?id=82365
>> + *
>> + * Adding an empty inline assembly before it works around the problem
>> + */
>> +#define barrier_before_unreachable() asm volatile("")
>> +
>> +/*
>>   * Mark a position in code as unreachable.  This can be used to
>>   * suppress control flow warnings after asm blocks that transfer
>>   * control elsewhere.
>> @@ -214,7 +223,11 @@
>>   * unreleased.  Really, we need to have autoconf for the kernel.
>>   */
>>  #define unreachable() \
>> -     do { annotate_unreachable(); __builtin_unreachable(); } while (0)
>> +     do {                                    \
>> +             annotate_unreachable();         \
>> +             barrier_before_unreachable();   \
>> +             __builtin_unreachable();        \
>> +     } while (0)
>
> Unfortunately this breaks microMIPS builds (e.g. MIPS
> micro32r2_defconfig and micro32r2el_defconfig) on gcc 7.2, due to the
> lack of .insn in the asm volatile. Because of the
> __builtin_unreachable() there is no code following it. Without the empty
> asm the compiler will apparently put the .insn there automatically, but
> with the empty asm it doesn't. Therefore the assembler won't treat an
> immediately preceeding label as pointing at 16-bit microMIPS
> instructions which need the ISA bit set, i.e. bit 0 of the address.
> This causes assembler errors since the branch target is treated as a
> different ISA mode:
>
> arch/mips/mm/dma-default.s:3265: Error: branch to a symbol in another ISA=
 mode
> arch/mips/mm/dma-default.s:5027: Error: branch to a symbol in another ISA=
 mode

Ok, I see.

> Due to a compiler bug on gcc 4.9.2 -> somewhere before 7.2, Paul
> submitted these patches a while back:
> https://patchwork.linux-mips.org/patch/13360/
> https://patchwork.linux-mips.org/patch/13361/
>
> Your patch (suitably fixed for microMIPS) would I imagine fix that issue
> too (it certainly fixes the resulting link error on microMIPS builds
> with an old toolchain).
>
> Before I forward port those patches to add .insn for MIPS, is that sort
> of approach (an arch specific asm/compiler-gcc.h to allow MIPS to
> override barrier_before_unreachable()) an acceptable fix?

That sounds fine to me. However, I would suggest making that
asm/compiler.h instead of asm/compiler-gcc.h, so we can also
use the same file to include workarounds for clang if needed.

       Arnd
