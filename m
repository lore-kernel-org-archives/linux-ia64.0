From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 07 Mar 2014 03:37:00 +0000
Subject: Re: [PATCH 2/2] kallsyms: handle special absolute symbols
Message-Id: <8761nqzo4z.fsf@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1394152324-26304-1-git-send-email-keescook@chromium.org> <1394152324-26304-3-git-send-email-keescook@chromium.org>
In-Reply-To: <1394152324-26304-3-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrew Honig <ahonig@google.com>, Michal Marek <mmarek@suse.cz>, "x86@kernel.org" <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, keescook@chromium.org, linux-kernel@vger.kernel.org

Kees Cook <keescook@chromium.org> writes:
> This forces the entire per_cpu range to be reported as absolute without
> losing their linker symbol types. Without this, the variables are
> incorrectly shown as relocated under kASLR.

I like these patches, thanks!

This one's a bit broken, since the zero-based __per_cpu_start/end thing
is an x86-64-ism.  You really do want them relocated on other
platforms, so I think you'll need do make this conditional via
a --per-cpu-absolute flag to kallsyms (which x86-64 would set).

Dumb Q: why don't we actually present these symbols as absolute in
/proc/kallsyms?  Seems like it would be clearer...

Thanks,
Rusty.
