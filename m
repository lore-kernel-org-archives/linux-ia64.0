From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 23 Mar 2001 04:26:24 +0000
Subject: Re: [Linux-ia64] kernel update (second patch relative to 2.4.2)
Message-Id: <marc-linux-ia64-105590693005342@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005334@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005334@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Yes.  I reported a bug related to stop bit generation a week ago or so
>to both you and Bernd.

It was only 3 days ago, but yeah, that needs to be fixed as soon as
possible.

>a fix already.  It worries me that you let C++ EH hold up this bug
>fix.  The unwinder in gcc is incomplete.  It will certainly fail when

I agree that the gcc unwinder is complete.  However, I don't think you are
being fair when considering C++ EH.  You personally care only about the
kernel unwinder.  But there are probably more people who care about C++ EH
than whether the kernel can use an unwinder.

Also, there are FSF rules and regulations that I need to follow here.
Official FSF policy is that I can't check in a patch that causes regressions
to the compiler.  There are of course exceptions to the rule, but they have
to be used very carefully.  C++ EH regressions count in this consideration.
Kernel unwinder regressions do not.  Thus it is best if I fix C++ EH
regressions before checking in the patch.

Jim

