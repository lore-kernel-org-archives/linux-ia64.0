From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 02 Jan 2003 21:18:24 +0000
Subject: Re: [Linux-ia64] IA-32 emulation issues
Message-Id: <marc-linux-ia64-105590709805631@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805630@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805630@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 26 Dec 2002 13:27:29 -0800, Arun Sharma <arun.sharma@intel.com> said:

  Arun> I ran some IA-32 test suites last week that uncovered a bunch of issues
  Arun> in the IA-32 emulation layer that I wanted to report here.

  Arun> a) semctl doesn't check for bad cmd

  Arun> --- sys_ia32.c	Wed Jun  5 15:39:54 2002
  Arun> +++ sys_ia32.c.new	Thu Dec 19 17:27:50 2002
  Arun> @@ -2166,6 +2166,9 @@
  Arun> else
  Arun> fourth.__pad = (void *)A(pad);
  Arun> switch (third) {
  Arun> +	      default:
  Arun> +		err = -EINVAL;
  Arun> +		break;
  Arun> case IPC_INFO:
  Arun> case IPC_RMID:
  Arun> case IPC_SET:

I applied this patch to the 2.5 tree.

  Arun> b) getdents64 - the system call succeeds, but glibc sets EOVERFLOW. We
  Arun> may want to think about getting rid of "struct linux32_dirent" at
  Arun> some point.

  Arun> History from glibc sources:

  Arun> /* The getdents64 syscall was introduced in 2.4.0-test7.  We test for
  Arun> 2.4.1 for the earliest version we know the syscall is available.  */
  Arun> #if __LINUX_KERNEL_VERSION >= 132097
  Arun> # define __ASSUME_GETDENTS64_SYSCALL    1
  Arun> #endif

If you muck with this, it'd probably be best to put it in fs/compat.c
at the same time.

  Arun> c) readv and iov_len

  Arun> Single UNIX spec says that readv should return:

  Arun> [EINVAL]
  Arun> The sum of the iov_len values in the iov array overflowed an ssize_t.

  Arun> The following (untested) patch should fix it. There may be a case for
  Arun> moving this check into userland.

  Arun> --- linux/fs/read_write.c	Mon Dec 16 01:06:56 2002
  Arun> +++ linux/fs/read_write.c.new	Thu Dec 19 16:41:33 2002
  Arun> @@ -26,6 +26,7 @@
  Arun> #include <linux/uio.h>
  Arun> #include <linux/smp_lock.h>
  Arun> #include <linux/dnotify.h>
  Arun> +#include <linux/personality.h>

  Arun> #include <asm/uaccess.h>

  Arun> @@ -268,7 +269,10 @@

  Arun> FIXME: put in a proper limits.h for each platform */
  Arun> #if BITS_PER_LONG=64
  Arun> -		if (tot_len > 0x7FFFFFFFFFFFFFFFUL)
  Arun> +		if ((current->personality & PER_LINUX32) 
  Arun> +                    && (tot_len > 0x7FFFFFFFUL))
  Arun> +		    goto out;
  Arun> +		else if (tot_len > 0x7FFFFFFFFFFFFFFFUL)
  Arun> #else
  Arun> if (tot_len > 0x7FFFFFFFUL)
  Arun> #endif

Generic code generally shouldn't be hacked for compatibility support.
Instead, we can create a syscall wrapper, like we do for all other
cases of similar nature.  That way, the native case doesn't get
impacted by the compatibility layer.

  Arun> d) msgctl(id, IPC_STAT, &buf) does't behave as expected

  Arun> This seems to be related to linux/ipc.h:

  Arun> #if defined(__ia64__) || defined(__hppa__)
  Arun> /* On IA-64 and PA-RISC, we always use the "64-bit version" of the IPC structures.  */
  Arun> # define ipc_parse_version(cmd)	IPC_64
  Arun> #else
  Arun> int ipc_parse_version (int *cmd);
  Arun> #endif

  Arun> However, sys_ia32.c:msgctl32 does a version check against IPC_64 to
  Arun> figure out whether to use struct msqid_ds or msqid64_ds. I think it
  Arun> should always be using msqid64_ds, given the above comment.

Yes, I suspect some more translation is required in the
syscall-compatibility layer.

Thanks,

	--david

