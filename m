From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Wed, 02 May 2012 05:46:53 +0000
Subject: Re: why is sigreturn() skipping some code on the way out of kernel?
Message-Id: <20120502054653.GJ6871@ZenIV.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120501233743.GI6871@ZenIV.linux.org.uk>
In-Reply-To: <20120501233743.GI6871@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 01, 2012 at 10:09:52PM -0600, David Mosberger-Tang wrote:
> Al,
> 
> AFAIR (which isn't saying much), it's correct.  sigreturn() is not a normal
> syscall.  The code that's being jumped over normally ensures that the
> syscall args that were passed into a syscall are present in user-level upon
> returning from the syscall.  However, since sigreturn() does a non-local
> return, that behavior would be wrong.  For my own reference (and the other
> few people who still might have a copy of my book): this is described on
> page 233, last paragraph.

Umm...  Well, if you've taken a signal with a handler, return to userland
is also non-local, in pretty much the same sense.

I really don't know how it's done on ia64, but in very general terms what
happens on signal arrival is better described if you look at syscalls,
interrupts and exceptions as coroutine calls - you get the state of userland
task saved on entry (and it may depend on the way we'd entered the kernel);
usually large part of the saved state is in pt_regs, but there might be more
to it.  sys_foo() operates on that saved state (well, the function itself
+ bits of glue right around its call).  You not so much return to userland
as resume it, by the saved state.  Handling a signal with userland handler
is basically
	* possibly handle restarts, by updating the saved state
	* encode the saved state and store it in sigcontext et.al.
	* switch the saved state to "entering the handler"
	* resume userland at the new saved state
while sigreturn is
	* decode the saved state from sigcontext
	* if we take signals, act as usual, except that no restarts are
to be done - all adjustments to the saved state we have at that point had
been done when we took that signal in the first place
	* resume userland at whatever saved state we got - either the
one we had encoded into sigcontext back then, or the one matching the
signal handler for signal we took (if we took any during sigreturn(),
that is).  In the latter case, the state that was decoded from sigcontext
gets reencoded into new sigcontext to be picked when we are done with that
new signal handler.

So if you have different actions for resuming userland (which is not unusual
and seems to be what you are talking about), sigreturn ought to match
the saved state when we took the signal.  I.e. in the simplest case (no
signals taken by sigreturn itself) it would depend on whether the signal
had been seen by syscall or by interrupt/exception.

AFAICS, you are using pSys/pNonSys for two things - restart suppression
(sigreturn _is_ equivalent to non-syscall in this respect) and choosing
how to restore the userland state.  And in that respect it's more
complicated.

I don't have your book, so if you could give a bit more details on that
thing...
