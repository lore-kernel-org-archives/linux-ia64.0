From: Thorsten Leemhuis <regressions@leemhuis.info>
Date: Wed, 02 Mar 2022 12:35:54 +0000
Subject: Re: regression: Bug 215601 - gcc segv at startup on ia64
Message-Id: <09fd50e3-7483-41ec-ee71-1a2ce8ff7b0f@leemhuis.info>
List-Id: <linux-ia64.vger.kernel.org>
References: <a3edd529-c42d-3b09-135c-7e98a15b150f@leemhuis.info>
 <ed02afd1-4e0f-4604-324c-0a58c0ca4b57@physik.fu-berlin.de>
In-Reply-To: <ed02afd1-4e0f-4604-324c-0a58c0ca4b57@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Anthony Yznaga <anthony.yznaga"@oracle.com, Kees Cook <keescook@chromium.org>
Cc: matoro_bugzilla_kernel@matoro.tk, Andrew Morton <akpm@linux-foundation.org>, "regressions@lists.linux.dev" <regressions@lists.linux.dev>, linux-ia64@vger.kernel.org, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>

On 02.03.22 13:01, John Paul Adrian Glaubitz wrote:
> On 2/20/22 18:12, Thorsten Leemhuis wrote:
>> I noticed a regression report in bugzilla.kernel.org that afaics nobody
>> acted upon since it was reported about a week ago, that's why I'm hereby
>> forwarding it to the lists and the relevant people. To quote
>> https://bugzilla.kernel.org/show_bug.cgi?id!5601 :
> As a heads-up, this issue has been fixed in 439a8468242b [1].
> 
>> [1] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?idC9a8468242b313486e69b8cc3b45ddcfa898fbf

Thx, but no need to in this particular, thx to the "Link:
https://lore.kernel.org/r/a3edd529-c42d-3b09-135c-7e98a15b150f@leemhuis.info"
that Kees included in the patch description. That allowed regzbot to
automatically notice the two new mailing lists threads where Kees posted
patches for testing and later also made regzbot notice the fix when it
landed in mainline:
https://linux-regtracking.leemhuis.info/regzbot/regression/a3edd529-c42d-3b09-135c-7e98a15b150f@leemhuis.info/

Sadly quite a few developers don't set such links tags, but I hope with
some education (and a improved regzbot that is a bit more useful at
least for subsystem maintainers) that will improve over time.

Ciao, Thorsten
