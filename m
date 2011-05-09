From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Mon, 09 May 2011 22:19:09 +0000
Subject: Re: [PATCH] Don't mlock guardpage if the stack is growing up
Message-Id: <1304979549.4865.56.camel@mulgrave.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.2.00.1105082045250.15552@artax.karlin.mff.cuni.cz>
	 <alpine.LSU.2.00.1105081303540.16151@sister.anvils>
	 <alpine.DEB.2.00.1105091307570.32299@artax.karlin.mff.cuni.cz>
	 <BANLkTinCUQSjjif3op3H_9HDm5Eu-o+Luw@mail.gmail.com>
	 <BANLkTim3kKJkisZK1mOgKhsEEs7FzZmyXA@mail.gmail.com>
In-Reply-To: <BANLkTim3kKJkisZK1mOgKhsEEs7FzZmyXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, Michel Lespinasse <walken@google.com>, Oleg Nesterov <oleg@redhat.com>, linux-ia64@vger.kernel.org

On Mon, 2011-05-09 at 15:07 -0700, Linus Torvalds wrote:
> Regardless, I'd like to hear whether this patch really does work on
> PA-RISC and especially IA64. I think those are the only cases that
> have a GROWSUP stack. And the IA64 case that supports both is the most
> interesting, everybody else does just one or the other.

So I can test the patch, if you tell me how.  I don't use lvm2, so it
would have to be a simple test case.

James


