From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 19 Dec 2017 20:13:12 +0000
Subject: Re: [PATCH] bug.h: Work around GCC PR82365 in BUG()
Message-Id: <CAK8P3a2fXQHCN7gqNL9j7AeZqy7NXAMW1bqyFJs3G1M_M4BQ4A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171219114112.939391-1-arnd@arndb.de> <8e42a1de-f619-7a4e-6d58-f90f53f5f38f@synopsys.com>
In-Reply-To: <8e42a1de-f619-7a4e-6d58-f90f53f5f38f@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "David S. Miller" <davem@davemloft.net>, Christopher Li <sparse@chrisli.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Will Deacon <will.deacon@arm.com>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, Mark Rutland <mark.rutland@arm.com>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-cris-kernel@axis.com" <linux-cris-kernel@axis.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-sparse@vger.kernel.org" <linux-sparse@vger.kernel.org>

On Tue, Dec 19, 2017 at 5:57 PM, Vineet Gupta
<Vineet.Gupta1@synopsys.com> wrote:
> On 12/19/2017 03:41 AM, Arnd Bergmann wrote:

>> In case of ARC and CRIS, it turns out that the BUG() implementation
>> actually does return (or at least the compiler thinks it does), resulting
>> in lots of warnings about uninitialized variable use and leaving noreturn
>> functions, such as:
>>
>> block/cfq-iosched.c: In function 'cfq_async_queue_prio':
>> block/cfq-iosched.c:3804:1: error: control reaches end of non-void
>> function [-Werror=return-type]
>> include/linux/dmaengine.h: In function 'dma_maxpq':
>> include/linux/dmaengine.h:1123:1: error: control reaches end of non-void
>> function [-Werror=return-type]

>> diff --git a/arch/arc/include/asm/bug.h b/arch/arc/include/asm/bug.h
>> index ea022d47896c..21ec82466d62 100644
>> --- a/arch/arc/include/asm/bug.h
>> +++ b/arch/arc/include/asm/bug.h
>> @@ -23,7 +23,8 @@ void die(const char *str, struct pt_regs *regs, unsigned
>> long address);
>>     #define BUG()       do {
>> \
>>         pr_warn("BUG: failure at %s:%d/%s()!\n", __FILE__, __LINE__,
>> __func__); \
>> -       dump_stack();
>> \
>> +       barrier_before_unreachable();
>> \
>> +       __builtin_trap();
>> \
>>   } while (0)
>>     #define HAVE_ARCH_BUG
>
>
> I suppose BUG() implies "dead end" like semantics - which ARC was lacking
> before ?

Correct. Using __builtin_trap() here avoids the 'control reaches end of non-void
function' warnings, but then makes us run into the stack size problem that
I work around with the barrier_before_unreachable().

It would be good if you could give this a quick test to see if you get sensible
output from the __builtin_trap();

         Arnd
