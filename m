From: "Robboy, David G" <david.g.robboy@intel.com>
Date: Tue, 27 Mar 2001 01:31:36 +0000
Subject: [Linux-ia64] smp_call_function / handle_IPI bug
Message-Id: <marc-linux-ia64-105590693005355@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The linux kernel function smp_call_function does this:

	Set variable 'smp_call_function_data' to point to data (this is both
a pointer and a lock)
	Send IPI interrupts to other processors
	Wait a good long time
	If other processors haven't responded
		clear the lock (which also nulls out the pointer)
		return
	if (wait)
		wait for execution to complete
	clear the lock
	return

The function handle_IPI() dereferences the pointer 'smp_call_function_data'
in order to get its data.

It can happen that a processor is busy for a long time and finally gets
around to handling an IPI, when the sender of the IPI has already given up
and cleared the lock.  In that case, handle_IPI() dereferences a null
pointer and panics the kernel.  I can demonstrate that it's possible.

Before dereferencing the pointer, handle_IPI should check for a null pointer
and "break" if it is null.  This simple fix does not guarantee that the
value of smp_call_function_data is still what the sender of the IPI
intended, but I propose that it's up to the programmer to  synchronize his
threads correctly.  The kernel does not have to enforce correct
synchronization, but it should not panic itself.

The fix I recommend is in the IPI_CALL_FUNC case of
smp_call_function_data(), check for a null pointer and break if it is null.

I'll be glad to submit a patch for R2.4.1 if there is no disagreement with
this solution and if someone will tell me where to send the patch.

David Robboy

	


