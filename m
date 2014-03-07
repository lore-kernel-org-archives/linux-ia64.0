From: Kees Cook <keescook@chromium.org>
Date: Fri, 07 Mar 2014 05:37:37 +0000
Subject: Re: [patch 10/20] kallsyms: fix absolute addresses for kASLR
Message-Id: <CAGXu5jK2z5uKnqnnXuFqrGSheQkKL5CmL0S0kAOk-XWpezbu8g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k3c8yr9u.fsf@rustcorp.com.au>
In-Reply-To: <87k3c8yr9u.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 6, 2014 at 7:20 PM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> Kees Cook <keescook@chromium.org> writes:
>> On Wed, Mar 5, 2014 at 6:50 PM, Rusty Russell <rusty@rustcorp.com.au> wrote:
>>> Kees Cook <keescook@chromium.org> writes:
>>>> [+x86 folks]
>>>>
>>>> On Tue, Mar 4, 2014 at 7:57 AM, Linus Torvalds
>>>> <torvalds@linux-foundation.org> wrote:
>>>>> On Mon, Mar 3, 2014 at 3:55 PM, Kees Cook <keescook@chromium.org> wrote:
>>>>>> This got NAKed, please don't apply -- this patch works for x86 and
>>>>>> ARM, but may cause problems for others:
>>>>>
>>>>> I'd much rather fix x86 and ARM, than worry about avr32.
>>>>>
>>>>> Priorities, people.
>>>>>
>>>>> Somebody who knows how "fix this properly" is supposed to work?
>>>>
>>>> I have not yet had a chance to more carefully examine the options, but
>>>> AIUI, the problem is that (at least) the "per cpu" variables are
>>>> neither absolute nor relative addresses from a relocation perspective.
>>>> They're relative to the per cpu area, but the linker tools don't know
>>>> about that state. So, I think, to fix this correctly, we need to teach
>>>> the linker tools about this third state. This may also help
>>>> arch/x86/tools/relocs, which is currently using a whitelist for
>>>> mis-identified variables.
>>>
>>> Well, __per_cpu_start points into a real section, within the discarded
>>> init region.  Makes me wonder why it's zero in /proc/kallsyms (it is on
>>> my Ubuntu system here too).
>>>
>>> ... digging ...
>>>
>>> Ah, the zero-based percpu patches, of course.  Gah.
>>>
>>> How's this?  Did I break IA64?
>>>
>>> =>>> kallsyms: make zero-based __per_cpu_start & __per_cpu_end absolute symbols.
>>>
>>> Andy reported that x86-64 with CONFIG_RANDOMIZE_BASE has bogus values
>>> for __per_cpu_start and __per_cpu_end in /proc/kallsyms:
>>
>> Well, just to make sure it's clear: __per_cpu_start/_end are just
>> markers, and everything between them is mishandled as well, not just
>> things named "__per_cpu" ...
>
> Gah... they should all be absolute, really, but that's going to be
> harder.
>
>>> -               PERCPU_INPUT(cacheline)                                 \
>>> +               VMLINUX_SYMBOL(__per_cpu_start) = ABSOLUTE(.);          \
>>> +               __PERCPU_INPUT(cacheline)                               \
>>> +               VMLINUX_SYMBOL(__per_cpu_end) = ABSOLUTE(.);            \
>>
>> I think this portion interacts badly with the x86 relocs tool which is
>> trying to find the per_cpu area via percpu_init(), which looks for the
>> section name ".data..percpu".
>
> What is "the x86 relocs tool"?

arch/x86/tools/relocs.c is used to generate relocation information on
x86-32 (always) and x86-64 (under kASLR). It deals with all kinds of
weird special cases that various linkers do differently. I'm glad I
didn't have to touch this code again. :)

-Kees

-- 
Kees Cook
Chrome OS Security
