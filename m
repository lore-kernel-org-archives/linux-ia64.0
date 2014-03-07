From: Kees Cook <keescook@chromium.org>
Date: Fri, 07 Mar 2014 00:32:02 +0000
Subject: [PATCH 0/2] kallsyms: handle special absolute symbols
Message-Id: <1394152324-26304-1-git-send-email-keescook@chromium.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrew Honig <ahonig@google.com>, Michal Marek <mmarek@suse.cz>, "x86@kernel.org" <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, keescook@chromium.org, linux-kernel@vger.kernel.org

This is an attempt at a more correct solution to the patch sent
earlier "kallsyms: fix absolute addresses for kASLR".

The main problem is that the entire per_cpu area needs to be treated 
as absolute by kallsyms. This series adds the logic to recognize the
per_cpu memory range and treat it as absolute in the kallsyms tool.

-Kees
