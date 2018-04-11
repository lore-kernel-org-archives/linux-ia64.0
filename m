From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 11 Apr 2018 10:08:51 +0000
Subject: Re: [PATCH] bug.h: Work around GCC PR82365 in BUG()
Message-Id: <CAK8P3a2_ihWCuUvDz_SVA1TMomkO1d7pa6e2bOQkZcEVP+Ff-A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171219114112.939391-1-arnd@arndb.de> <20180410224805.GA21429@saruman>
 <CAK8P3a0-_u7_FCj-nH0izBv4ub6krm1uA32bwi2jtBzXJePcnQ@mail.gmail.com> <20180411095359.GB21429@saruman>
In-Reply-To: <20180411095359.GB21429@saruman>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Hogan <jhogan@kernel.org>
Cc: "open list:RALINK MIPS ARCHITECTURE" <linux-mips@linux-mips.org>, Paul Burton <paul.burton@mips.com>, Maciej Rozycki <macro@mips.com>, linux-arch <linux-arch@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Vineet Gupta <vgupta@synopsys.com>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "David S. Miller" <davem@davemloft.net>, Christopher Li <sparse@chrisli.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Will Deacon <will.deacon@arm.com>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, Mark Rutland <mark.rutland@arm.com>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m68k@vger.kernel.org, sparclinux <sparclinux@vger.kernel.org>, linux-sparse@vger.kernel.org, linux-alpha@vger.kernel.org

On Wed, Apr 11, 2018 at 11:54 AM, James Hogan <jhogan@kernel.org> wrote:
> On Wed, Apr 11, 2018 at 09:30:56AM +0200, Arnd Bergmann wrote:
>> On Wed, Apr 11, 2018 at 12:48 AM, James Hogan <jhogan@kernel.org> wrote:
>> > Before I forward port those patches to add .insn for MIPS, is that sort
>> > of approach (an arch specific asm/compiler-gcc.h to allow MIPS to
>> > override barrier_before_unreachable()) an acceptable fix?
>>
>> That sounds fine to me. However, I would suggest making that
>> asm/compiler.h instead of asm/compiler-gcc.h, so we can also
>> use the same file to include workarounds for clang if needed.
>
> Yes, though there are a few asm/compiler.h's already, and the alpha one
> includes linux/compiler.h before undefining inline, so seems to have its
> own specific purpose...

Interesting. For the other ones, including asm/compiler.h from linux/compiler.h
seems appropriate though, so the question would be what to do with the
alpha case. I think we can simply remove that header file and replace
it with this patch:

diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
index b2022885ced8..5502404f54cd 100644
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -81,6 +81,9 @@ config PGTABLE_LEVELS
        int
        default 3

+config OPTIMIZE_INLINING
+       def_bool y
+
 source "init/Kconfig"
 source "kernel/Kconfig.freezer"

which should have the same effect.
