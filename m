From: Tony Luck <tony.luck@gmail.com>
Date: Mon, 09 May 2011 23:08:44 +0000
Subject: Re: [PATCH] Don't mlock guardpage if the stack is growing up
Message-Id: <BANLkTikLJPCc5ffobAb5uhdryRqjGhpVAQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.2.00.1105082045250.15552@artax.karlin.mff.cuni.cz>
	<alpine.LSU.2.00.1105081303540.16151@sister.anvils>
	<alpine.DEB.2.00.1105091307570.32299@artax.karlin.mff.cuni.cz>
	<BANLkTinCUQSjjif3op3H_9HDm5Eu-o+Luw@mail.gmail.com>
	<BANLkTim3kKJkisZK1mOgKhsEEs7FzZmyXA@mail.gmail.com>
	<1304979549.4865.56.camel@mulgrave.site>
	<BANLkTim7ATRyJ2NvoCj4Sv=7CLizKMd_WA@mail.gmail.com>
	<BANLkTi=DCKmN_BafFckKHOMfjWpVLQPDFA@mail.gmail.com>
	<BANLkTikkA5H2D23u23FV0cTcL2bAT8BKWQ@mail.gmail.com>
In-Reply-To: <BANLkTikkA5H2D23u23FV0cTcL2bAT8BKWQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>, Fenghua Yu <fenghua.yu@intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, Michel Lespinasse <walken@google.com>, Oleg Nesterov <oleg@redhat.com>, linux-ia64@vger.kernel.org

On Mon, May 9, 2011 at 3:58 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> Ahh, so you never actually have one single mapping that has both flags set?
>
> In that case, I won't even worry about it.

Definitely not for normal processes - I'm not sure how both stacks are
set up for threads.

> One thing I did want to verify: did the mlockall() actually change the
> stack size without that patch? Just to double-check that the patch
> actually did change semantics visibly.

On an unpatched system I see this (lots more than one page of growth -
pages are 64K on this config):
6007fffffff50000-6007fffffff70000 rw-p 00000000 00:00 0
6007fffffff50000-6008000000750000 rw-p 00000000 00:00 0

On a patched system I see (this one has 16K pages - no growth)
600007ffff9d0000-600007ffff9d4000 rw-p 00000000 00:00 0
600007ffff9d0000-600007ffff9d4000 rw-p 00000000 00:00 0

-Tony
