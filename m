From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 18 Jun 2003 03:33:23 +0000
Subject: [Linux-ia64] Re: gettimeofday patch
Message-Id: <marc-linux-ia64-105590709805947@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:


David> So, the moral of the story (which we already knew): it's _hard_
David> to write correct light-weight syscall handlers.  Clearly,
David> anytime a new handler is written, some careful testing is
David> advised (in particular with respect to passing NaT arguments,
David> invalid pointers, etc.).  It would be great to have a
David> Stanford-checker that can statically analyze the validity of a
David> light-weight system call handler.  It should be very difficult
David> to do and it would clearly be easier to code-up the dozen or so
David> rules once than to have to remember them every time.  Perhaps
David> somebody's summer project some day?

Yes, the rules are such that:
     -- it's easy to violate them without noticing, especially if one's
        not that good at assembly programming in the first place
     -- you can't use C

and writing optimised assembly language for IA64 is hard anyway.

Louis started with no knowledge of IA64 architecture, and almost no
internals knowledge of the Linux kernel.  In four weeks he got to the
point where he could write the optimised gettimeofday(), and determine
that an optimised epoll() was more trouble than it was worth.

It'd be nice if the rules could be relaxed a bit, to allow (a
restricted subset of) ordinary kernel C code to be invoked from a
lightweight syscall handler.  The main issue is IMO the RSE, and info
leakage into its backing store.  Page and translation faults can be
dealt with, with a bit of care and some extra code.

In the meantime, I worry a bit about the assembler code, and the
possibility of it getting out-of-sync with the rest of the kernel,
given that it is so hard to code it correctly.  It's probably only
worth writing fast syscall routines for stuff where the system call
duration really matters (e.g., gettimeofday()).

Peter C

