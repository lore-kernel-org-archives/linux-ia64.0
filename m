From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 16 Nov 2007 20:05:35 +0000
Subject: Re: [PATCH] ptrace RSE bug
Message-Id: <473DF80F.6020705@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Roland McGrath wrote:
>> I found it extremely difficult to trigger the race condition without the
>> articifial test - arch_ptrace_stop() only sleeps if the user page is not
>> present, but in the common case the register stack backing store will
>> have been quite recently accessed by the process.
> 
> It is supposed to be a rare race, after all. :-)  We're just being thorough
> to cover it, not that it ever actually happened in practice or was expected to.
> 
>> It should be possible to create a large file, flush the page cache, put
>> the RSE into lazy mode, flush it and map the register stack from that
>> file, so that no memory accesses to the backing store are done before
>> ptrace_stop(), but for the time being I placed an msleep(100) after
>> arch_ptrace_stop().
> 
> And then make the file so mapped be from a broken NFS or FUSE or somesuch
> mount that actually blocks forever on the fault.  That would be the
> probable style of a DoS attack exploiting this to create unkillable processes.
> 
>> Anyway, I produced a test case which succeeds when the call to
>> sigkill_pending() is in and fails when it's commented out. I'm attaching
>> it here (the kernel patch to follow).
> 
> Ok!  It sounds like we've verified all the pieces of the fix.
> 
> There's one more wrinkle that I've remembered.  A traced process has not
> necessarily gone through ptrace_stop when you do ptrace on it, though
> normally so.  It can be in job control stop (TASK_STOPPED), such as when
> you attach gdb to something stopped by ^Z.  To cover that case, the easiest

Interesting. I've just tried attaching to a stopped process and gdb
hangs on wait4(). When I resume the process, gdb complains like this:

/build/buildd/gdb-6.4.90.dfsg/gdb/linux-nat.c:1025: internal-error:
linux_nat_attach: Assertion `pid = GET_PID (inferior_ptid) &&
WIFSTOPPED (status) && WSTOPSIG (status) = SIGSTOP' failed.
A problem internal to GDB has been detected,
further debugging may prove unreliable.
Quit this debugging session? (y or n)

So, it seems to me that attaching to stopped processes is broken anyway,
because debugger expect to get a notification signal when they do
PTRACE_ATTACH. Shouldn't the kernel generate one? (Which would BTW also
make the special handling of ptrace_attach for our purposes unnecessary.)

Regards,
Petr Tesarik

