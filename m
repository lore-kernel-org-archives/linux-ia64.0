From: stefan <stefan@lkcc.org>
Date: Thu, 20 Sep 2001 22:09:11 +0000
Subject: Re: [Linux-ia64] getcontext() correctly implemented ?
Message-Id: <marc-linux-ia64-105590698805232@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805230@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805230@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 20 Sep 2001, David Mosberger wrote:

> To get the full machine context, in a signal handler, you'd have to
> either (a) use stack unwinding to recover the preserved state at the
> point of the signal or (b) use a combination of sigcontext and
> setjmp() or getcontext().  Can say a little more about what you're
> trying to do?  That would make it easier to give a specific example.
> 
> To accomplish (a), we really need a user-level unwinder.  It's been on
> the todo list for some time, but nobody got around to implement it, so
> far.

The garbage collector of GNU Guile does not need the machine context in a
signal handler. It just looks for heap references within the programs
stack. The top of the stack is saved when starting the program, the bottom
is gained from the current stack position when garbage collecting. More
references might be within the machines registers. That is why it uses
setjmp() in order to get these into a defined buffer. On a ia64 Linux
setjump() is not said to save *all* registers. That is why I thought the
getcontext() function could help here. Is that true ? I already tried it
with glibc 2.2.3 without success. Still missed some references...

Thanks in advance,
	stefan@lkcc.org


