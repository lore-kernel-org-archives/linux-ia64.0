From: Tony Luck <tony.luck@gmail.com>
Date: Mon, 09 May 2011 22:53:33 +0000
Subject: Re: [PATCH] Don't mlock guardpage if the stack is growing up
Message-Id: <BANLkTi=DCKmN_BafFckKHOMfjWpVLQPDFA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.2.00.1105082045250.15552@artax.karlin.mff.cuni.cz>
	<alpine.LSU.2.00.1105081303540.16151@sister.anvils>
	<alpine.DEB.2.00.1105091307570.32299@artax.karlin.mff.cuni.cz>
	<BANLkTinCUQSjjif3op3H_9HDm5Eu-o+Luw@mail.gmail.com>
	<BANLkTim3kKJkisZK1mOgKhsEEs7FzZmyXA@mail.gmail.com>
	<1304979549.4865.56.camel@mulgrave.site>
	<BANLkTim7ATRyJ2NvoCj4Sv=7CLizKMd_WA@mail.gmail.com>
In-Reply-To: <BANLkTim7ATRyJ2NvoCj4Sv=7CLizKMd_WA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>, Fenghua Yu <fenghua.yu@intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, Michel Lespinasse <walken@google.com>, Oleg Nesterov <oleg@redhat.com>, linux-ia64@vger.kernel.org

On Mon, May 9, 2011 at 3:31 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> With current kernels, I think the stack expands by one page during the
> mlockall (for STACK_GROWSUP), with the patch it shouldn't.

Tried this on ia64 (with a mod because the upward growing stack isn't
blessed with
the [stack] annotation, only the downward growing stack gets that honour).

ia64 builds, boots, and processes can still grow stacks (both of them).  The
patched kernel doesn't change the size of the upwardly growing stack across
the mlockall().

-Tony

P.S. while we could start both stacks on the same page and have the grow
away from the start point, ia64 actually starts them out a fair distance apart
and lets them run into each other (if you have enough memory to let them
grow that far, and if ulimit -s doesn't stop them earlier)
