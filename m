From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 10 Mar 2014 20:02:24 +0000
Subject: Re: [PATCH v2 0/2] kallsyms: handle special absolute symbols
Message-Id: <20140310130224.70ec6a1940ec636bfb89f6bb@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1394240425-11647-1-git-send-email-keescook@chromium.org>
	<20140310120657.80aa5569714e5b53c6662798@linux-foundation.org>
	<CAGXu5j+9Qt2p+dqdqcecMQ4RRb8tBVMqMDBdRGFjiRQHmDaatQ@mail.gmail.com>
In-Reply-To: <CAGXu5j+9Qt2p+dqdqcecMQ4RRb8tBVMqMDBdRGFjiRQHmDaatQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Honig <ahonig@google.com>, Michal Marek <mmarek@suse.cz>, "x86@kernel.org" <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 10 Mar 2014 12:58:06 -0700 Kees Cook <keescook@chromium.org> wrote:

> On Mon, Mar 10, 2014 at 12:06 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Fri,  7 Mar 2014 17:00:23 -0800 Kees Cook <keescook@chromium.org> wrote:
> >> Handles 0-based per_cpu variables as being absolute so they are
> >> not relocated under kASLR on x86_64.
> >
> > Would it be prudent to revert 0f55159d091cb1e5 ("kallsyms: fix absolute
> > addresses for kASLR") then sort all this out for 3.15?
> 
> My opinion is that if it breaks a real-life case (avr32), it should be
> reverted.

We aren't going to be able to test this on 40 architectures so yes,
let's take the cautious approach.

> The only people affected by the kallsyms per_cpu relocation
> reporting bug are those using kASLR on x86, and even then the bug is a
> corner case on live kernel debugging.
> 
> I am fine either way.

