From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 16 Jan 2003 23:44:52 +0000
Subject: Re: [Linux-ia64] IA64 watchpoint traps not reported in system calls
Message-Id: <marc-linux-ia64-105590709805708@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805707@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805707@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 16 Jan 2003 18:07:00 -0500, Robert Faught <rtf@etnus.com> said:

  Robert> A watchpoint set using an IA64 debug data register is
  Robert> ignored when the location is accessed by a system call such
  Robert> as read.

Yes, that's the expected behavior: watch points are programmed to
trigger only when running at the user-level (privilege level 3).

  Robert> It would be very good to have the data watch triggered from
  Robert> inside the kernel reported to the user (or more likely the
  Robert> user`s debugger), since if you`re trying to find out what is
  Robert> stomping one of your variables you expect setting a
  Robert> watchpoint on it to tell you, whether or not the stomping is
  Robert> happening as a result of passing bad arguments to a system
  Robert> call.

I see your point, but don't see any easy solution: I think it's way
too dangerous to allow them to trigger at privilege level 0 (because
of speculation and because of the risk of spurious matches when
running with address translation disabled; it definitely would also
require special handling for fsyscalls, because we currently rely on
watchpoints not triggering at privilege level 0).

The cost of elevating the privilege level during user-memory accesses
would be prohibitive.

We could use faulting "probe" instructions in the kernel as an
alternative, but doing so would also slow down the user-access
routines so much that it would be unacceptable (especially since
_every_ byte would have to be "probe"d to make watchpoints work all
the time).

Unless someone has another idea, I suspect this is a limitation we'll
have to live with.  It doesn't strike me as a huge issue: it's not
unlike shared memory, which can change "underneath" you as well
(without a watchpoint catching it, I mean).

	--david

