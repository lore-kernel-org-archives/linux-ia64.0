From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 14 Feb 2001 19:19:07 +0000
Subject: [Linux-ia64] more on setjmp()/longjmp()
Message-Id: <marc-linux-ia64-105590693005148@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A while ago I wrote:

  (2) The current setjmp()/longjmp() implementation cannot be used for
      stack switching purposes, because it does not preserve ar.rnat.
      There was some discussion on what we should do about this and the
      conclusion was to fix the routines so they do preserve ar.rnat.
      The main argument for changing the routines was that the IA-64
      SCRA requires ar.rnat to be part of the jmp_buf.

Well, it turns out the SCRA was not quite clear on this topic:
apparently the _intent_ was not to require a flushrs in setjmp() and
the requirement of saving ar.rnat was indirectly contradicting this
intent.  I understand the SCRA is being fixed so that this will be
made clearer (and ar.rnat is no longer mentioned as a register that
must be saved in the jump buffer).

Because of this, I'd like to recommend that we keep the current
setjmp()/longjmp() implementation.  The implication of this is that
the routines may not be used for switching stacks.  If an application
needs to do this, it should use the *context() routines (which still
need to be implemented...).

Don, could you update the setjmp() TODO list entry accordingly?

Thanks,

	--david

