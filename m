From: Nicholas Piggin <npiggin@gmail.com>
Date: Mon, 27 Aug 2018 07:43:43 +0000
Subject: Re: [PATCH] treewide: remove current_text_addr
Message-Id: <20180827161121.07aa9da6@roar.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAKwvOdkWL_2yTnJqM6n6R9UCPwY4iz-9BQYGN2MDAk9EzumUvA@mail.gmail.com>
 <20180821202900.208417-1-ndesaulniers@google.com>
 <207784db-4fcc-85e7-a0b2-fec26b7dab81@gmx.de>
 <c62e4e00-fb8f-19a6-f3eb-bde60118cb1a@zytor.com>
 <81141365-8168-799b-f34f-da5f92efaaf9@zytor.com>
 <7f49eeab-a5cc-867f-58fb-abd266f9c2c9@zytor.com>
 <6ca8a1d3-ff95-e9f4-f003-0a5af85bcb6f@zytor.com>
 <CA+55aFzuSCKfmgT9efHuwtan+m3+bPh4BpwbZwn5gGX_H=Thuw@mail.gmail.com>
In-Reply-To: <CA+55aFzuSCKfmgT9efHuwtan+m3+bPh4BpwbZwn5gGX_H=Thuw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

[ Trimmed the cc list because my SMTP didn't accept that many
addresses. ]

On Sun, 26 Aug 2018 13:25:14 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Sun, Aug 26, 2018 at 12:32 PM H. Peter Anvin <hpa@zytor.com> wrote:
> >
> > Here is a full-blown (user space) test program demonstrating the whole
> > technique and how to use it.  
> 
> So while I agree that some _THIS_IP_ users might be better off being
> converted to __builtin_return_address(0) at the caller, I also think
> that the whole "notailcall" thing shows why that can easily be more
> problematic than just our currnet _THIS_IP_ solution.
> 
> Honestly, I'd suggest:
> 
>  - just do the current_text_addr() to _THIS_IP_ conversion
> 
>  - keep _THIS_IP_ and make it be the generic one, and screw the whole
> "some architectures might implement is better" issue. Nobody cares.
> 
>  - try to convince people to move away from the "we want the kernel
> instruction pointer for the call" model entirely, and consider this a
> "legacy" issue.
> 
> The whole instruction pointer is a nasty thing. We should discourage
> it and not make complex infrastructure for it.
> 
> Instead, maybe we could encourage something like
> 
>   struct kernel_loc { const char *file; const char *fn; int line; };
> 
>   #define __GEN_LOC__(n) \
>         ({ static const struct kernel_loc n = { \
>                 __FILE__, __FUNCTION__, __LINE__  \
>            }; &n; })
> 
>   #define _THIS_LOC_ __GEN_LOC__(__UNIQUE_ID(loc))
> 
> which is a hell of a lot nicer to use, and actually allows gcc to
> optimize things (try it: if you pass a _THIS_LOC_ off to an inline
> function, and that inline function uses the name and line number, gcc
> will pick them up directly, without the extra structure dereference.
> 
> Wouldn't it be much nicer to pass these kinds of "location pointer"
> around, rather than the nasty _THIS_IP_ thing?

Seems nice. Do you even need this unique ID thing? AFAIKS the name
would never really be useful.

It could perhaps go into a cold data section too, I assume the common
case is that you do not access it. Although gcc will end up putting
the file and function names into regular rodata.

Possibly we could add a printk specifier for it, pass it through to
existing BUG, etc macros that want exactly this, etc. Makes a lot of
sense.

Thanks,
Nick
