From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 14 Dec 2000 05:13:06 +0000
Subject: Re: [Linux-ia64] switch_stack position
Message-Id: <marc-linux-ia64-105590678205831@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205821@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205821@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 13 Dec 2000 20:39:17 -0800, 
David Mosberger <davidm@hpl.hp.com> wrote:
>Note that the unwind code is written such that it cannot fault, even
>if the initial state on the stack is completely bogus.  This is why
>it's safe to call get_wchan() on a process that's running.

Safe but it gives misleading results which confuse people doing
debugging.  I had the same problem on kdb for ia32.  Doing backtrace of
the running process on cpu 0 from cpu 1 (btp pid) gave different
results compared to backtrace of the current process on cpu 0 (bt).
Debuggers should not give different results for the same process just
because you are looking from another cpu.

The solution is the same on ia32 and ia64.  The debugger attempts to
get all processes into a known state.  That state is recorded in struct
task.  Then the debugger can look at any process from any cpu and see a
consistent state.


