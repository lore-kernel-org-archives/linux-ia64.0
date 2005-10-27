From: Cliff Wickman <cpw@sgi.com>
Date: Thu, 27 Oct 2005 20:18:50 +0000
Subject: Re: [PATCH 1/2] ia64: ptrace - find memory sharers on children list
Message-Id: <20051027201850.GA25930@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4360F244.mailxI4A11KHTU@eag09.americas.sgi.com>
In-Reply-To: <4360F244.mailxI4A11KHTU@eag09.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 27, 2005 at 11:03:46AM -0700, Luck, Tony wrote:
> >The ptrace caller (presumably a debugger) specifies the pid of
> >its target and an address to peek or poke.  But the debugger could be
> >attached to several tasks.
> 
> Perhaps I'm being overly dense here (I haven't ever tried to
> debug a multi-threaded application) ... but how can this situation
> happen?  Since ptrace takes a "pid" argument, I'd expect that any
> activities performed by the kernel in response to that ptrace call
> would be restricted to just the process that was mentioned.  Searching
> off through other processes to see if any of them have the data
> just sounds wrong.  Why can't the debugger keep track of which
> process is which and give the right "pid" to the ptrace call?
> 
> -Tony

These are the comments from arch/ia64/kernel/ptrace.c:
  /*
   * GDB apparently wants to be able to read the register-backing store of
   * any thread when attached to a given process.  If we are peeking or
   * poking an address that happens to reside in the kernel-backing store
   * of another thread, we need to attach to that thread, because otherwise
   * we end up accessing stale data.
 
In other words (as I understand it) the specified pid is some member of
the multitasked application and represents the whole application.  I agree
that it would be nice if the debugger passed us the pid of the specific
task whose register image it wants to peek or poke.  But apparently it is
not constrained by such a rule.

If we are peeking at some task's register backing storage we must be
sure that that task is inactive and its registers stored to memory or else
we get a register image that is not current.  find_thread_for_addr() is
called to find that task.

-Cliff

-- 
Cliff Wickman
Silicon Graphics, Inc.
cpw@sgi.com
(651) 683-3824
