From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 20 Sep 2001 18:26:35 +0000
Subject: Re: [Linux-ia64] getcontext() correctly implemented ?
Message-Id: <marc-linux-ia64-105590698805231@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805230@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805230@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 Sep 2001 19:34:00 +0200 (CEST), stefan <stefan@lkcc.org> said:

  Stefan> Hello list, in order to save the full register set of the
  Stefan> ia64 I want to use getcontext(&ctx) instead of
  Stefan> setjmp(jmpbuf) and check the registers in ctx.uc_mcontext
  Stefan> for references in a garbage collected system.

The *context() routines are designed to support synchronous context
switches only (see glibc FAQ).  Thus, they basically save the
"preserved" state only.

  Stefan> My question is: Is getcontext() correctly implemented in
  Stefan> glibc(). Which version do I need and can I use it for the
  Stefan> described purpose at all ?

It's implemented to meet the requirements of SuS.  In that sense, it
should be correct (you'll probably need glibc 2.2.4 as there were some
silly bugs in earlier versions).

To get the full machine context, in a signal handler, you'd have to
either (a) use stack unwinding to recover the preserved state at the
point of the signal or (b) use a combination of sigcontext and
setjmp() or getcontext().  Can say a little more about what you're
trying to do?  That would make it easier to give a specific example.

To accomplish (a), we really need a user-level unwinder.  It's been on
the todo list for some time, but nobody got around to implement it, so
far.

	--david

