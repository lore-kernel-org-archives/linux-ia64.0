From: Kees Cook <keescook@chromium.org>
Date: Sat, 08 Mar 2014 01:00:23 +0000
Subject: [PATCH v2 0/2] kallsyms: handle special absolute symbols
Message-Id: <1394240425-11647-1-git-send-email-keescook@chromium.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrew Honig <ahonig@google.com>, Michal Marek <mmarek@suse.cz>, "x86@kernel.org" <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, keescook@chromium.org, linux-kernel@vger.kernel.org

Handles 0-based per_cpu variables as being absolute so they are
not relocated under kASLR on x86_64.

-Kees

