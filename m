From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 08 Jan 2002 19:12:45 +0000
Subject: [Linux-ia64] Re: can we make anonymous memory non-EXECUTABLE?
Message-Id: <marc-linux-ia64-105590698805776@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805771@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805771@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 07 Jan 2002 22:02:08 -0800 (PST), "David S. Miller" <davem@redhat.com> said:

  DaveM> I assume this hack is "have a software EXECUTE bit, initially
  DaveM> only set the software one, when we take a fault on execute
  DaveM> set the hardware bit and maybe flush the Icache".  If so,
  DaveM> what is the big deal? :-)

Yes.  Hey, don't get me wrong: I'm *proud* of that solution, but if
the alternative is to completely get rid of the problem in the first
place, that is always preferable (simplicity rules).

  DaveM> I think changing this behavior is going to silently break
  DaveM> things on many architectures.

I don't consider SIGSEGV to be a silent failure.  Also, I think
all the evidence is that it's unlikely to break many existing
apps:

	o The bug I described has been present for *years* on
	  Alpha and probably all other platforms other than x86;
	  even on ia64 it took almost two years before someone
	  noticed.  It's possible that nobody noticed because
	  the code generators were part of a larger program,
	  but it's very likely that anyone writing a test program
	  would have allocated the non-executable memory, so you'd
	  expect *someone* to have run into it at some point.

	o Certain libraries such as the Boehm Garbage Collector
	  already turn off execute permission by default.  While
	  there may not be that many apps that use it in a production
	  environment, it is my impression that many developers are
	  using it as a memory-leak detector (e.g., Mozilla does that).


  DaveM> Secondly, I do not see any
  DaveM> real gain from any of this and my ports are those that have
  DaveM> I-cache coherency issues :-)

I think that's fine.  If the consensus is that apps *should* use
mprotect() to get executable permission (Linus implied as much) and
it's an architecture specific choice as to whether this is enforced,
I'm happy.  My belief is that we could make this change on ia64
without undue burden on programmers.  If not, I'm sure I'll find out
about it and I'm willing to take the responsibility.

	--david

