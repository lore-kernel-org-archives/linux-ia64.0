From: Keith Owens <kaos@sgi.com>
Date: Fri, 28 Mar 2003 01:39:14 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-ia64-021210 new spinlock code
Message-Id: <marc-linux-ia64-105590723705349@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805543@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805543@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 27 Mar 2003 15:32:52 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Fri, 28 Mar 2003 10:15:02 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> The code does not rely on any implementation specific
>  Keith> behaviour.  Stating that ar.pfs is zero is well defined, it
>  Keith> means that the caller (rp in r28) of this code has no frame.
>
>No, an unwinder might check whether a stacked register is out of the
>current frame and complain if so.  Ergo, it's implementation-dependent
>behavior.

The only unwinder I care about is in the kernel and that handles this
condition.  libunwind also accepts this condition.  Both unwinders
check that the stacked register is within the current backing store,
not within the current frame.  You are rejecting working, faster and
better debugging code because some hypothetical unwinder might detect
an error one day.  Even if this hypothetical unwinder did detect an
error, it would simply stop the unwind.

>Want to guess why the NEW_LOCK code was never enabled?  If you want to
>add the code with an #if 0, that's fine with me.

The new spinlock code is faster, shrinks the kernel, allows for
exponential backoff and better debugging.  It should be the default in
all kernels, with an option to disable it for people with strange
unwinders.

Disable out of line spinlock code
CONFIG_IA64_DISABLE_OOL_SPINLOCK
  By default, IA64 uses out of line code for the spinlock contention
  path.  This shrinks the size of the kernel, makes uncontended locks
  faster and allows for exponential backoff and debugging on contended
  locks.

  It uses an unusual unwind mechanism that may not work if you use an
  unwinder other than the one in the kernel.  Even if your unwinder
  does not work, the only effect will be an incomplete unwind for code
  that is stuck in the spinlock contention path, this has no effect on
  the kernel itself.

  If you know that you have an IA64 unwinder that cannot cope with the
  out of line spinlock code, say Y and live with a kernel that is
  larger, slower and cannot debug hung spinlocks.  Otherwise say N.

Acceptable?


