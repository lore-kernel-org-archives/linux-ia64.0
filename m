From: Roland McGrath <roland@redhat.com>
Date: Wed, 14 Nov 2007 06:47:16 +0000
Subject: RE: [PATCH] ptrace RSE bug
Message-Id: <20071114073249.DE96026F67D@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I found it extremely difficult to trigger the race condition without the
> articifial test - arch_ptrace_stop() only sleeps if the user page is not
> present, but in the common case the register stack backing store will
> have been quite recently accessed by the process.

It is supposed to be a rare race, after all. :-)  We're just being thorough
to cover it, not that it ever actually happened in practice or was expected to.

> It should be possible to create a large file, flush the page cache, put
> the RSE into lazy mode, flush it and map the register stack from that
> file, so that no memory accesses to the backing store are done before
> ptrace_stop(), but for the time being I placed an msleep(100) after
> arch_ptrace_stop().

And then make the file so mapped be from a broken NFS or FUSE or somesuch
mount that actually blocks forever on the fault.  That would be the
probable style of a DoS attack exploiting this to create unkillable processes.

> Anyway, I produced a test case which succeeds when the call to
> sigkill_pending() is in and fails when it's commented out. I'm attaching
> it here (the kernel patch to follow).

Ok!  It sounds like we've verified all the pieces of the fix.

There's one more wrinkle that I've remembered.  A traced process has not
necessarily gone through ptrace_stop when you do ptrace on it, though
normally so.  It can be in job control stop (TASK_STOPPED), such as when
you attach gdb to something stopped by ^Z.  To cover that case, the easiest
thing I can see is to define an arch_ptrace_attach macro that does the
writeback.  This requires making the ia64_rse_writeback function (or
whatever it's to be called) work on either current or another task that's
stopped.  i.e.

#define arch_ptrace_attach(child) \
	do if (!test_tsk_thread_flag(child, TIF_RESTORE_RSE) && \
	       ptrace_check_attach(child, 0) = 0) \
		ia64_writeback_rse(child); \
	while (0)


Thanks,
Roland
