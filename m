From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 02 May 2003 07:13:12 +0000
Subject: Re: [Linux-ia64] avoid exceptions in copy_from_user?
Message-Id: <marc-linux-ia64-105590723705629@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705628@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705628@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 2 May 2003 16:43:37 +1000, Martin Pool <mbp@samba.org> said:

  Martin> This is probably a flawed idea but I was just curious: could
  Martin> the kernel use speculative loads to avoid taking exceptions
  Martin> when a copy_from_user or related function faults?
  Martin> (Something like the routine below.)

You're right, it's flawed. ;-)

First problem: why optimize the _exceptional_ case?  Show me one
application which suffers from the cost of the exception handling and
I'll buy you a beer (or two or three).  OTOH, almost every application
benefits from optimizing the common case of exception-free execution.

Second (and perhaps more important) problem: kernel code must not
assume that a speculative load fails only if the load cannot possibly
execute successfully (in ia64 lingo, this is called the "recovery"
model, as opposed to the "no-recovery" model, which I'm not a fan of).
For example, depending on the DCR settings, a speculative load may
also fail on a TLB miss.  Of course, you don't want the code to fail
just because of a TLB miss.

  Martin> I suspect the answer is that it's not worthwhile, because if
  Martin> the copy fails then the kernel is about to go and do
  Martin> something expensive like paging or killing the task, and so
  Martin> a little more overhead is not important, and anyhow adding
  Martin> instructions to the non-failing case is undesirable.

Yup.

My experience so far is that speculative loads are best left to the
compiler.  Human beings are just not very good at writing recovery
code and keeping it in sync with the main code (e.g., we had some
painful experiences with the strncpy() routine).

	--david

