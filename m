From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 05 Dec 2001 02:15:50 +0000
Subject: Re: [Linux-ia64] Bug in signal handling
Message-Id: <marc-linux-ia64-105590698805614@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805573@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805573@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 Dec 2001 17:14:26 -0800, Richard Henderson <rth@redhat.com> said:

  Richard> On Mon, Dec 03, 2001 at 06:19:52PM -0800, David Mosberger
  Richard> wrote:
  >> Richard, I'm cc'ing you because it appears to me that Alpha Linux
  >> may have the same problem.

  Richard> I don't think it does:

  Richard> That is, after do_signal we restore registers and return.

  Richard> Unless you meant something else?

Oh, sorry, I was referring to teh *other* problem... ;-)

What I meant is that the check for re-scheduling
(current->need_resched) and signal deliverify (current->sigpending)
needs to be done with interrupts turned off, and the interrupts need
to be left off until user space is reached.  Otherwise, you could get
an interrupt which would wake up a higher priority task or post a
signal between the check and the return to user space.

I didn't see this interrupt disabling in the Alpha version of entry.S,
but I have to admit my Alpha assembly is getting quite rusty.

	--david

