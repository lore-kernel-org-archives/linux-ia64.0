From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Wed, 02 Mar 2022 12:01:16 +0000
Subject: Re: regression: Bug 215601 - gcc segv at startup on ia64
Message-Id: <ed02afd1-4e0f-4604-324c-0a58c0ca4b57@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <a3edd529-c42d-3b09-135c-7e98a15b150f@leemhuis.info>
In-Reply-To: <a3edd529-c42d-3b09-135c-7e98a15b150f@leemhuis.info>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thorsten Leemhuis <regressions@leemhuis.info>, "Anthony Yznaga <anthony.yznaga"@oracle.com, Kees Cook <keescook@chromium.org>
Cc: matoro_bugzilla_kernel@matoro.tk, Andrew Morton <akpm@linux-foundation.org>, "regressions@lists.linux.dev" <regressions@lists.linux.dev>, linux-ia64@vger.kernel.org, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>

Hi Thorsten!

On 2/20/22 18:12, Thorsten Leemhuis wrote:
> I noticed a regression report in bugzilla.kernel.org that afaics nobody
> acted upon since it was reported about a week ago, that's why I'm hereby
> forwarding it to the lists and the relevant people. To quote
> https://bugzilla.kernel.org/show_bug.cgi?id!5601 :

As a heads-up, this issue has been fixed in 439a8468242b [1].

Adrian

> [1] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?idC9a8468242b313486e69b8cc3b45ddcfa898fbf

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
