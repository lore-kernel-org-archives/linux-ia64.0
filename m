From: Keith Owens <kaos@sgi.com>
Date: Mon, 06 Dec 2004 23:51:48 +0000
Subject: Re: [RFC] I/O error handling for userspace
Message-Id: <25772.1102377108@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412030831.25662.jbarnes@engr.sgi.com>
In-Reply-To: <200412030831.25662.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 6 Dec 2004 08:59:45 -0800, 
Jesse Barnes <jbarnes@engr.sgi.com> wrote:
>On Monday, December 6, 2004 4:42 am, Hidetoshi Seto wrote:
>> force_sig_info() takes spinlock in it... I think calling this isn't safe on
>> MCA.
>
>This is the only bit I'm unsure about.  I can't just add a spin_trylock 
>version, since the call path for send_sig_info calls the slab allocator, 
>which takes other locks.
>
>Assuming that only the CPU that caused the MCA is in the MCA handler (i.e. 
>rendezvous doesn't occur), then the only time that one of the spinlocks could 
>hang is if the current CPU also owned it, right?  Hmm, maybe the 
>ia64_spinlock_contention routine could check for a machine check condition 
>and promote the failure to an uncorrectable one in that case?  That's pretty 
>ugly though...

The best option I can come up with is to record the fact that we need
sigbus and save the failing io_addr and range->owner in per cpu
variables.  In arch/ia64/kernel/entry.S work_pending, test for
a pending sigbus from MCA and send the signal from there, using the
saved data.  IOW, send the signal on the next return from kernel to
user space on the current cpu, not from the MCA handler.

To check from a pending signal from MCA, define TIF_SIGNAL_MCA in
thread_info.h.  Adding TIF_SIGNAL_MCA as a work flag will require some
adjustments to TIF_WORK_MASK and TIF_ALLWORK_MASK, no big deal.
Checking the extra flag has no impact on the existing ia64_leave_kernel
code path unless the flag is set, we check for all the flags in a
single mask test.

The offending task might be sleeping waiting for I/O completion which
will never occur now.  OTOH the current task could be the one that was
interrupted by the MCA.  To ensure that the task (a) gets woken up and
(b) cannot do any more useful work, set TIF_SIGNAL_MCA on both the
current task and the offending task.  Whichever task goes through
ia64_leave_kernel next will send the signal, from the right context.

