From: Keith Owens <kaos@sgi.com>
Date: Sat, 06 Dec 2003 22:50:19 +0000
Subject: Re: Deadlock in ia64_mca_cmc_int_caller
Message-Id: <marc-linux-ia64-107075105715673@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107068420607204@msgid-missing>
In-Reply-To: <marc-linux-ia64-107068420607204@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 06 Dec 2003 08:23:50 -0700, 
Alex Williamson <alex.williamson@hp.com> wrote:
>   We debugged a similar problem with the old CMC/CPE code recently. 
>However, the latest version in 2.4/2.6 fixed that problem.  So are you
>actually hitting a deadlock when ia64_mca_cmc_int_caller() calls
>smp_call_function(ia64_mca_cmc_vector_enable, NULL, 1, 0)?

Yes, at the point that smp_call_function is spinning on

  while (atomic_read(&data.started) != cpus)

The cpus that were not responding were spinning disabled waiting for
tasklist_lock.  The assumption is that tasklist_lock is held by the
current cpu.

>I've reached
>the same conclusion about smp_call_function, my mistake for using it in
>the first place, it's way too dangerous.

Using smp_call_function in any interrupt context is unsafe, we should
add a badness check to smp_call_function for that state.  I think that
bh context is bad as well, but need to confirm that.  Of course it is
not interrupt/bh context per se that is bad, but the interaction of
those contexts with spinlocks that are sometimes taken enabled and
sometimes disabled and synchronizing across cpus.

>We need to enable/disable the
>CMC vector in a better context or use another mechanism.

Since the only safe time to use smp_call_function is with no spinlocks
held on the current cpu, that restricts us to a user context thread.
Create a kernel thread called smp_call_nowait that waits on a semaphore
which CMC/CPE does up() on.  Use a list of kmalloc(GFP_ATOMIC)
structures containing

  list_head
  void (*func) (void *info)
  void *info
  char info_data[variable]

When smp_call_nowait wakes up, it takes the first entry off the list,
calls smp_call_function with wait=1 then kfrees the list entry.  The
'_nowait' part of the thread name indicates that the original caller
does not wait for the smp function to take effect.

I will code this up on Monday.

