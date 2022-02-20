From: Thorsten Leemhuis <regressions@leemhuis.info>
Date: Sun, 20 Feb 2022 17:12:06 +0000
Subject: regression: Bug 215601 - gcc segv at startup on ia64
Message-Id: <a3edd529-c42d-3b09-135c-7e98a15b150f@leemhuis.info>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Anthony Yznaga <anthony.yznaga"@oracle.com, Kees Cook <keescook@chromium.org>
Cc: matoro_bugzilla_kernel@matoro.tk, Andrew Morton <akpm@linux-foundation.org>, "regressions@lists.linux.dev" <regressions@lists.linux.dev>, linux-ia64@vger.kernel.org, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>

Hi, this is your Linux kernel regression tracker.

I noticed a regression report in bugzilla.kernel.org that afaics nobody
acted upon since it was reported about a week ago, that's why I'm hereby
forwarding it to the lists and the relevant people. To quote
https://bugzilla.kernel.org/show_bug.cgi?id!5601 :

> On ia64, after 5f501d555653f8968011a1e65ebb121c8b43c144, the gcc
> binary crashes with SIGSEGV at startup (i.e., during ELF loading).
> Only gcc exhibits the crash (including g++, etc), other toolchain
> components (such as ld, ldd, etc) do not, and neither does any other
> binary from what I can tell.  I also haven't observed the issue on
> any other architecture.
> 
> Reverting this commit resolves the issue up to and including git tip,
> with no (visible) issues.
> 
> Hardware:  HP Integrity rx2800 i2 Kernel config attached.

Could somebody take a look into this? Or was this discussed somewhere
else already? Or even fixed?

Anyway, to get this tracked:

#regzbot introduced: 5f501d555653f8968011a1e65ebb121c8b43c144
#regzbot from: matoro <matoro_bugzilla_kernel@matoro.tk>
#regzbot title: gcc segv at startup on ia64
#regzbot link: https://bugzilla.kernel.org/show_bug.cgi?id!5601

Ciao, Thorsten (wearing his 'the Linux kernel's regression tracker' hat)

P.S.: As the Linux kernel's regression tracker I'm getting a lot of
reports on my table. I can only look briefly into most of them and lack
knowledge about most of the areas they concern. I thus unfortunately
will sometimes get things wrong or miss something important. I hope
that's not the case here; if you think it is, don't hesitate to tell me
in a public reply, it's in everyone's interest to set the public record
straight.

-- 
Additional information about regzbot:

If you want to know more about regzbot, check out its web-interface, the
getting start guide, and the references documentation:

https://linux-regtracking.leemhuis.info/regzbot/
https://gitlab.com/knurd42/regzbot/-/blob/main/docs/getting_started.md
https://gitlab.com/knurd42/regzbot/-/blob/main/docs/reference.md

The last two documents will explain how you can interact with regzbot
yourself if your want to.

Hint for reporters: when reporting a regression it's in your interest to
CC the regression list and tell regzbot about the issue, as that ensures
the regression makes it onto the radar of the Linux kernel's regression
tracker -- that's in your interest, as it ensures your report won't fall
through the cracks unnoticed.

Hint for developers: you normally don't need to care about regzbot once
it's involved. Fix the issue as you normally would, just remember to
include 'Link:' tag in the patch descriptions pointing to all reports
about the issue. This has been expected from developers even before
regzbot showed up for reasons explained in
'Documentation/process/submitting-patches.rst' and
'Documentation/process/5.Posting.rst'.
