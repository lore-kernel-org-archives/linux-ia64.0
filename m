From: Kees Cook <keescook@chromium.org>
Date: Thu, 13 Mar 2014 06:23:37 +0000
Subject: Re: [PATCH v2 2/2] kallsyms: handle special absolute symbols
Message-Id: <CAGXu5jJvbdLqCNwrbrV-k-j2-=mDuccoodu3OuQg6eEduCvkqQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1394240425-11647-1-git-send-email-keescook@chromium.org>
	<1394240425-11647-3-git-send-email-keescook@chromium.org>
	<CAGXu5j+QoHH004usCiCfJU6DPQFnQ2gt3P4GDLS7Gx8Tz_gK+A@mail.gmail.com>
	<87y50fuei5.fsf@rustcorp.com.au>
	<CAGXu5j+Zto=D_UYgn6DLVcOQyB_8sAs86masY8iuDTU5ZEZ8OQ@mail.gmail.com>
	<87lhwevk98.fsf@rustcorp.com.au>
In-Reply-To: <87lhwevk98.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrew Honig <ahonig@google.com>, Michal Marek <mmarek@suse.cz>, "x86@kernel.org" <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Mar 12, 2014 at 8:40 PM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> Kees Cook <keescook@chromium.org> writes:
>> Why not just do this with 0-base-address detection like my v2? That
>> would mean we don't need to remember to add this flag in the future to
>> imagined new architectures that might want this 0-based per_cpu
>> feature.
>
> Because future architectures will get this right and emit absolute
> symbols.  I hope!
>
> I'm swamped at the moment, but am hoping to investigate that for
> x86-64.  This is a stop-gap.

Okay, I'm convinced. :)

Acked-by: Kees Cook <keescook@chromium.org>

Thanks!

-Kees

-- 
Kees Cook
Chrome OS Security
