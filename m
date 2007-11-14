From: Shaohua Li <shaohua.li@intel.com>
Date: Wed, 14 Nov 2007 05:38:44 +0000
Subject: RE: [PATCH] ptrace RSE bug
Message-Id: <1195018724.14672.4.camel@sli10-conroe.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2007-11-13 at 12:07 +0100, Petr Tesarik wrote:
> On Mon, 2007-11-12 at 16:30 -0800, Roland McGrath wrote:
> > [...]
> > If you do the artificial test using a long sleep in arch_ptrace_stop,
> > then you can probably produce this by hand with gdb.  Have the process
> > doing raise(SIGCHLD) or some other harmless signal.  The traced
> > process will stop to report the signal to gdb, and then gdb will sit
> > at the prompt before resuming it (given "handle SIGFOO stop" if not default).  
> > If your sleep is long enough, it won't be hard to get your SIGKILL in there.
> > Then when gdb is sitting, the traced process may still be sitting too.
> > But it should have gone away instantly from SIGKILL.
> 
> I found it extremely difficult to trigger the race condition without the
> articifial test - arch_ptrace_stop() only sleeps if the user page is not
> present, but in the common case the register stack backing store will
> have been quite recently accessed by the process.
> 
> It should be possible to create a large file, flush the page cache, put
> the RSE into lazy mode, flush it and map the register stack from that
> file, so that no memory accesses to the backing store are done before
> ptrace_stop(), but for the time being I placed an msleep(100) after
> arch_ptrace_stop().
> 
> Anyway, I produced a test case which succeeds when the call to
> sigkill_pending() is in and fails when it's commented out. I'm attaching
> it here (the kernel patch to follow).
So without the sigkill_pending() check, your test case will print an
error, and otherwise, nothing. This is expected output, right? Looks I
can reproduce it here.

I'll refresh the RSE fix to align with Roland's patch.
