From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 14 Dec 2000 07:20:04 +0000
Subject: Re: [Linux-ia64] switch_stack position
Message-Id: <marc-linux-ia64-105590678205839@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205821@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205821@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Dec 2000 18:08:19 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> There is no guarantee that I can stop all the cpus.
  Keith> Sometimes the problem is so bad that the cpu will not accept
  Keith> the IPI.  This is exactly the case when a debugger needs to
  Keith> be able to print the processor on the unresponsive cpu, or at
  Keith> the very least to say what state the process is in.

If the CPU is still running, there is no guarantee that the existence
of a switch-stack implies that the process is stopped.  For example,
it may just be unwinding the stack via unw_init_running() and by the
time kdb attempts to read the stack, the switch-stack may have
disappeared again.

  Keith> kdb can detect unresponsive cpus and will not let you switch
  Keith> to them but you can still issue 'btp pid' to get some data
  Keith> for the offending cpu.  And that needs the location of the
  Keith> last switch_stack for the process.

Have you actually tried doing a "btp" on an IA-64 stack that isn't
valid?  I think you'll find that unw_unwind() returns -1 long before
unwinding to user-space.  That's probably as good an indication as any
that the stack is still active.

	--david

