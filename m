From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 14 Dec 2000 07:30:56 +0000
Subject: Re: [Linux-ia64] switch_stack position
Message-Id: <marc-linux-ia64-105590678205840@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205821@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205821@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 13 Dec 2000 23:20:04 -0800, 
David Mosberger <davidm@hpl.hp.com> wrote:
>>>>>> On Thu, 14 Dec 2000 18:08:19 +1100, Keith Owens <kaos@ocs.com.au> said:
>
>  Keith> There is no guarantee that I can stop all the cpus.
>  Keith> Sometimes the problem is so bad that the cpu will not accept
>  Keith> the IPI.  This is exactly the case when a debugger needs to
>  Keith> be able to print the processor on the unresponsive cpu, or at
>  Keith> the very least to say what state the process is in.
>
>If the CPU is still running, there is no guarantee that the existence
>of a switch-stack implies that the process is stopped.  For example,
>it may just be unwinding the stack via unw_init_running() and by the
>time kdb attempts to read the stack, the switch-stack may have
>disappeared again.

Possible but extremely unlikely.  If the cpu is not responding to IPI
then it is unlikely to be unwinding.  kdb IPI on ia32 uses NMI, I plan
to try using NMI for ia64 as well.  A cpu that does not respond to NMI
is in a sick state.

The other problem with a global per cpu array is debugging the
debugger.  There is some support in recent version of SGI kdb for
debugging kdb itself.  That requires stack data for the original fault
plus a separate set of stack data for the kdb error.  At which point I
need to store the current state plus the previous state, the stack is
the best place for this.

>  Keith> kdb can detect unresponsive cpus and will not let you switch
>  Keith> to them but you can still issue 'btp pid' to get some data
>  Keith> for the offending cpu.  And that needs the location of the
>  Keith> last switch_stack for the process.
>
>Have you actually tried doing a "btp" on an IA-64 stack that isn't
>valid?  I think you'll find that unw_unwind() returns -1 long before
>unwinding to user-space.  That's probably as good an indication as any
>that the stack is still active.

But I don't want unwind to return -1 or produce garbage, which is what
it occurs now when the stack state does not match the assumptions.  I
want it to use the last saved switch_stack for that process, it is the
only clean starting point for debugging.  A clean debug report is far
better than producing a random backtrace and sending users off on a
wild goose chase.


