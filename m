From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 10 Mar 2014 19:06:57 +0000
Subject: Re: [PATCH v2 0/2] kallsyms: handle special absolute symbols
Message-Id: <20140310120657.80aa5569714e5b53c6662798@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1394240425-11647-1-git-send-email-keescook@chromium.org>
In-Reply-To: <1394240425-11647-1-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Honig <ahonig@google.com>, Michal Marek <mmarek@suse.cz>, "x86@kernel.org" <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri,  7 Mar 2014 17:00:23 -0800 Kees Cook <keescook@chromium.org> wrote:

> Handles 0-based per_cpu variables as being absolute so they are
> not relocated under kASLR on x86_64.
> 

Would it be prudent to revert 0f55159d091cb1e5 ("kallsyms: fix absolute
addresses for kASLR") then sort all this out for 3.15?

