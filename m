From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 01 Mar 2003 06:14:24 +0000
Subject: [Linux-ia64] Re: gettimeofday patch
Message-Id: <marc-linux-ia64-105590709805948@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 1 Mar 2003 14:17:52 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

  David> So, the moral of the story (which we already knew): it's
  David> _hard_ to write correct light-weight syscall handlers.
  David> Clearly, anytime a new handler is written, some careful
  David> testing is advised (in particular with respect to passing NaT
  David> arguments, invalid pointers, etc.).  It would be great to
  David> have a Stanford-checker that can statically analyze the
  David> validity of a light-weight system call handler.  It should be
  David> very difficult to do and it would clearly be easier to
  David> code-up the dozen or so rules once than to have to remember
  David> them every time.  Perhaps somebody's summer project some day?

  Peter> Yes, the rules are such that:

  Peter> -- it's easy to violate them without noticing, especially if
  Peter> one's not that good at assembly programming in the first
  Peter> place

Yup.

  Peter> -- you can't use C and writing optimised assembly language
  Peter> for IA64 is hard anyway.

Agreed.  The best way to write assembler is to let the compiler do it
for you.

  Peter> Louis started with no knowledge of IA64 architecture, and
  Peter> almost no internals knowledge of the Linux kernel.  In four
  Peter> weeks he got to the point where he could write the optimised
  Peter> gettimeofday(), and determine that an optimised epoll() was
  Peter> more trouble than it was worth.

I was impressed with the original code _before_ I knew that.  Now I'm
blown away!  Talk about baptism by fire!  I'm sorry if my mail came
out sounding negative, that's not at all what I had intended.

  Peter> It'd be nice if the rules could be relaxed a bit, to allow (a
  Peter> restricted subset of) ordinary kernel C code to be invoked
  Peter> from a lightweight syscall handler.  The main issue is IMO
  Peter> the RSE, and info leakage into its backing store.  Page and
  Peter> translation faults can be dealt with, with a bit of care and
  Peter> some extra code.

I totally agree.  We could in fact support support several trade-off
points between lowest possible overhead and ease of use.  For example,
we could use the least-significant 4 bits in the handler's entry-point
to encode what kind of handler it is.  E.g., code 0 could mean the
current type of handler, code 1 could mean that the task-flags have
been checked already on entry and the registers get clared on exit,
and so on.

This stuff is all very new and I expect that it will take some
experimentation, time, and tools to figure out how to best do things.
It's a rich space for exploration, in my opinion.

  Peter> In the meantime, I worry a bit about the assembler code, and
  Peter> the possibility of it getting out-of-sync with the rest of
  Peter> the kernel, given that it is so hard to code it correctly.

I worry much more than a bit about that.  It's definitely a huge
issue.  It's OK with a handful of light-weight syscall handlers, but
it becomes quickly intractable as the number of handlers increases.

There are probably many syscalls that could be done profitably as
light-weight handlers (e.g., getrusage(), sigprocmask(), and
sigreturn() come to mind).  Stuff like sigreturn() may be OK because
it's almost entirely platform-dependent (i.e., it's under our
control), but the other stuff could be a royal pain to maintain.

  Peter> It's probably only worth writing fast syscall routines for
  Peter> stuff where the system call duration really matters (e.g.,
  Peter> gettimeofday()).

Yes.

I can imagine several tools that would be helpful:

 o A Stanford-checker-like static analysis tool that verifies that
   a given piece of object code follows the rules.

 o A special compiler mode where the compiler knows about which
   limitations apply and either avoids the limitations (e.g., avoids
   subroutine calls by aggressive inlining) or reports an error when
   it's unable to do so.

There is really no reason the compiler couldn't generate handlers for
stuff like getpid() and other things that are simple enough (assuming
it knows about the extra rules).  Plus it wouldn't surprise me if a
good compiler (say the Intel compiler or the HP compiler) would
actually generate _better_ code for stuff like gettimeofday().

	--david

