From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 09 May 2001 05:07:41 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.4)
Message-Id: <marc-linux-ia64-105590693005554@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest IA-64 patch is (finally) available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.4.4-ia64-010508.diff*.  Thanks to Johannes Erdfelt,
USB is working again and I hope this kernel will be quite stable for
everybody (famous last words...).

What's changed:

	- clean up boot parameter passing between elilo and kernel
	  (Stephane Eranian)
	- optimized do_csum() some more (Jun Nakajima)
	- AGP GART update (Chris Ahna)
	- fix pci-pool routines to work on 64-bit platforms (Johannes
          Erdfelt)
	- more IA-32 updates (Don Dugger, me)
	- make machine_halt() do nothing instead of rebooting the
	  machine; this has the desirable effect that "shutdown -h"
	  will really halt instead of rebooting the machine; the
	  machine does *not* power off, however (I don't think the
	  current firmware/hw supports this)
	- use KERNEL_PG_* constants instead of hardcoding the page
	  size used in the kernel's identity mapped regions (Tony Luck)
	- added getunwind() system call as a means to get unwind info
	  for the gate page (signal handler trampoline for now;
	  light-weight syscall stubs in the future) and add unwind info
	  to signal trampoline
	- move EFI vars from /proc/efi to /proc/efi/vars/ (Matt Domsch)
	- for MP machines, sync cycle counter register (ar.itc) of
	  each CPU with the time keeper CPU on boot up & exploit this
	  to provide fine-grained time in gettimeofday()
	- clean up & fix coredump creation
	- clean up debug messages in cs4281 drivers to avoid compiler
	  warnings
	- make the register backing store of a newly execve()'d
	  process start at a nicely aligned address again
	- fix spin_unlock() to do barrier() in correct place (Jack Steiner)
	- add a couple of spare longs to sigcontext structure to
	  provide room for future extensibility

Some notes: I didn't apply Jes's qla1280 clean up patch yet.  I'd very
much like to do that, but since qlogic is maintaing this driver, I'm
waiting until they've had a chance to review it.

If you look at the cycle counter sync'ing code, you'll see that it's
very different from what has been proposed in the past.  There is a
good reason for this: the new code allows arbitrary pairs of CPUs to
sync at any point in time.  At this point, the only time the syncing
is actually done is at boot time, but in the future we'll want to
support online replacement of CPUs and with a pair-wise syncing
approach, this is trivial to support.  Also, the new code uses a close
loop to sync the counters.  This ensures that there are no
unaccounted-for error sources.  The syncing tends to work quite well
in pratice: usually, we seem to get a pair of CPUs to within <10
cycles of each other (assuming that the interconnect between the two
CPUs has symmetric latencies).  However, I'm also quite sure that
someone with a better memory of control theory could optimize the
current code for faster convergence (and perhaps more stable behavior
in the presence of large amounts of noise).  Please feel free to take
this as a challenge! ;-)

BIG CAVEAT: even though the kernel currently is syncing the cycle
counters, application code MUST NOT rely on this.  Instead, if an
application needs fine-grained and light-weight timestamps, it should
use the POSIX *clock* routines that Uli added recently to libc.  I can
almost guarantee you that future machines will NOT have synchronized
clocks (and we'll also want to support systems where different CPUs
have different clock speeds) and because of this, the *clock* routines
and gettimeofday() are the recommended and RELIABLE way for obtaining
fine-grained timestamps.

Enjoy,

	--david

