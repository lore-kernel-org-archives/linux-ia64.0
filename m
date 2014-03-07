From: Kees Cook <keescook@chromium.org>
Date: Fri, 07 Mar 2014 05:42:41 +0000
Subject: Re: [PATCH 2/2] kallsyms: handle special absolute symbols
Message-Id: <CAGXu5jJKZbiOhnLTWw5YppCxjNWKSdjGd6Gt6Qz-zV1gkjg1Mg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1394152324-26304-1-git-send-email-keescook@chromium.org>
	<1394152324-26304-3-git-send-email-keescook@chromium.org>
	<8761nqzo4z.fsf@rustcorp.com.au>
In-Reply-To: <8761nqzo4z.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrew Honig <ahonig@google.com>, Michal Marek <mmarek@suse.cz>, "x86@kernel.org" <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 6, 2014 at 7:25 PM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> Kees Cook <keescook@chromium.org> writes:
>> This forces the entire per_cpu range to be reported as absolute without
>> losing their linker symbol types. Without this, the variables are
>> incorrectly shown as relocated under kASLR.
>
> I like these patches, thanks!

Oh good! Glad this is getting closer. :)

> This one's a bit broken, since the zero-based __per_cpu_start/end thing
> is an x86-64-ism.  You really do want them relocated on other
> platforms, so I think you'll need do make this conditional via
> a --per-cpu-absolute flag to kallsyms (which x86-64 would set).

Ah, hm. Can this maybe just be dynamically detected (e.g. if
__per_cpu_start = 0?), I'd hate to have another arch run into this
glitch when we could "notice" it and deal with it instead.

> Dumb Q: why don't we actually present these symbols as absolute in
> /proc/kallsyms?  Seems like it would be clearer...

You mean set "sym[0] = 'A'" instead of the force_absolute thing I
added? It seemed like I shouldn't mess with existing information, and
as you say, they're not absolute on all platforms.

-Kees

-- 
Kees Cook
Chrome OS Security
