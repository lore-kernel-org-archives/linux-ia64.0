From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 20 Dec 2017 09:01:27 +0000
Subject: Re: [PATCH] bug.h: Work around GCC PR82365 in BUG()
Message-Id: <CAK8P3a25RgC0qPCrGfutSnLHr77NqK74dW2g0m7fcMnm5Ou8yg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171219114112.939391-1-arnd@arndb.de> <8e42a1de-f619-7a4e-6d58-f90f53f5f38f@synopsys.com>
 <CAK8P3a2fXQHCN7gqNL9j7AeZqy7NXAMW1bqyFJs3G1M_M4BQ4A@mail.gmail.com> <f31caa9b-89f0-4168-04bf-14a98595865e@synopsys.com>
In-Reply-To: <f31caa9b-89f0-4168-04bf-14a98595865e@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "David S. Miller" <davem@davemloft.net>, Christopher Li <sparse@chrisli.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Will Deacon <will.deacon@arm.com>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, Mark Rutland <mark.rutland@arm.com>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-cris-kernel@axis.com" <linux-cris-kernel@axis.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-sparse@vger.kernel.org" <linux-sparse@vger.kernel.org>

On Tue, Dec 19, 2017 at 11:38 PM, Vineet Gupta
<Vineet.Gupta1@synopsys.com> wrote:
> On 12/19/2017 12:13 PM, Arnd Bergmann wrote:
>>
>>
>>> I suppose BUG() implies "dead end" like semantics - which ARC was lacking
>>> before ?
>>
>> Correct. Using __builtin_trap() here avoids the 'control reaches end of
>> non-void
>> function' warnings, but then makes us run into the stack size problem that
>> I work around with the barrier_before_unreachable().
>>
>> It would be good if you could give this a quick test to see if you get
>> sensible
>> output from the __builtin_trap();
>
>
> It does, added a BUG() arbit, hits an abort()
>
> ...
> ISA Extn    : atomic ll64 unalign (not used)
>         : mpy[opt 9] div_rem norm barrel-shift swap minmax swape
> BPU        : partial match, cache:2048, Predict Table:16384
> BUG: failure at ../arch/arc/mm/tlb.c:827/arc_mmu_init()!
>
>
> Tested-by: Vineet Gupta <vgupta@synopsys.com>

I meant whether it prints the right registers and stack trace, but I
assume you tested that and just did not list it above.

> FWIW newer ARC gcc actually implements the builtin so we get a trap 5
> instruction now, vs., abort() calls before.
>
> BTW I missed reading the hunk of your changelog where this addresses the
> long standing mystery with ARC builds and numerous -Wreturn-type warnings. I
> always wondered why they were not fixed upstream already, being too lazy to
> investigate myself, and turns out this was due to this BUG() thingy. phew !

Hmm, so with the new definition of abort(),

+__weak void abort(void)
+{
+   BUG();
+
+   /* if that doesn't kill us, halt */
+   panic("Oops failed to kill thread");
+}

won't that run into an endless recursion? Or do you then override abort()
for ARC?

         Arnd
