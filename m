From: Kees Cook <keescook@chromium.org>
Date: Tue, 26 Jul 2016 04:46:36 +0000
Subject: Re: [PATCH v3 02/11] mm: Hardened usercopy
Message-Id: <CAGXu5jJDHYfGwsULKqpWVykPB9TJHNy8pBELq-K08HnHGE2Tjw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
 <1468619065-3222-3-git-send-email-keescook@chromium.org> <5790711f.2350420a.b4287.2cc0SMTPIN_ADDED_BROKEN@mx.google.com>
 <CAGXu5jLCu1Vv0uugKZrsjSEsoABgXJSOJ8GkKmrHbvj9jkC2YA@mail.gmail.com>
 <20160722174551.jddle6mf7zlq6xmb@treble> <87poq1jgtw.fsf@concordia.ellerman.id.au>
In-Reply-To: <87poq1jgtw.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Mon, Jul 25, 2016 at 7:03 PM, Michael Ellerman <mpe@ellerman.id.au> wrote:
> Josh Poimboeuf <jpoimboe@redhat.com> writes:
>
>> On Thu, Jul 21, 2016 at 11:34:25AM -0700, Kees Cook wrote:
>>> On Wed, Jul 20, 2016 at 11:52 PM, Michael Ellerman <mpe@ellerman.id.au> wrote:
>>> > Kees Cook <keescook@chromium.org> writes:
>>> >
>>> >> diff --git a/mm/usercopy.c b/mm/usercopy.c
>>> >> new file mode 100644
>>> >> index 000000000000..e4bf4e7ccdf6
>>> >> --- /dev/null
>>> >> +++ b/mm/usercopy.c
>>> >> @@ -0,0 +1,234 @@
>>> > ...
>>> >> +
>>> >> +/*
>>> >> + * Checks if a given pointer and length is contained by the current
>>> >> + * stack frame (if possible).
>>> >> + *
>>> >> + *   0: not at all on the stack
>>> >> + *   1: fully within a valid stack frame
>>> >> + *   2: fully on the stack (when can't do frame-checking)
>>> >> + *   -1: error condition (invalid stack position or bad stack frame)
>>> >> + */
>>> >> +static noinline int check_stack_object(const void *obj, unsigned long len)
>>> >> +{
>>> >> +     const void * const stack = task_stack_page(current);
>>> >> +     const void * const stackend = stack + THREAD_SIZE;
>>> >
>>> > That allows access to the entire stack, including the struct thread_info,
>>> > is that what we want - it seems dangerous? Or did I miss a check
>>> > somewhere else?
>>>
>>> That seems like a nice improvement to make, yeah.
>>>
>>> > We have end_of_stack() which computes the end of the stack taking
>>> > thread_info into account (end being the opposite of your end above).
>>>
>>> Amusingly, the object_is_on_stack() check in sched.h doesn't take
>>> thread_info into account either. :P Regardless, I think using
>>> end_of_stack() may not be best. To tighten the check, I think we could
>>> add this after checking that the object is on the stack:
>>>
>>> #ifdef CONFIG_STACK_GROWSUP
>>>         stackend -= sizeof(struct thread_info);
>>> #else
>>>         stack += sizeof(struct thread_info);
>>> #endif
>>>
>>> e.g. then if the pointer was in the thread_info, the second test would
>>> fail, triggering the protection.
>>
>> FWIW, this won't work right on x86 after Andy's
>> CONFIG_THREAD_INFO_IN_TASK patches get merged.
>
> Yeah. I wonder if it's better for the arch helper to just take the obj and len,
> and work out it's own bounds for the stack using current and whatever makes
> sense on that arch.
>
> It would avoid too much ifdefery in the generic code, and also avoid any
> confusion about whether stackend is the high or low address.
>
> eg. on powerpc we could do:
>
> int noinline arch_within_stack_frames(const void *obj, unsigned long len)
> {
>         void *stack_low  = end_of_stack(current);
>         void *stack_high = task_stack_page(current) + THREAD_SIZE;
>
>
> Whereas arches with STACK_GROWSUP=y could do roughly the reverse, and x86 can do
> whatever it needs to depending on whether the thread_info is on or off stack.
>
> cheers

Yeah, I agree: this should be in the arch code. If the arch can
actually do frame checking, the thread_info (if it exists on the
stack) would already be excluded. But it'd be a nice tightening of the
check.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security
