From: Arun Sharma <arun.sharma@intel.com>
Date: Thu, 02 Jan 2003 23:31:04 +0000
Subject: Re: [Linux-ia64] IA-32 emulation issues
Message-Id: <marc-linux-ia64-105590709805633@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805630@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805630@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:
> 
>   Arun> b) getdents64 - the system call succeeds, but glibc sets EOVERFLOW. We
>   Arun> may want to think about getting rid of "struct linux32_dirent" at
>   Arun> some point.
> 
>   Arun> History from glibc sources:
> 
>   Arun> /* The getdents64 syscall was introduced in 2.4.0-test7.  We test for
>   Arun> 2.4.1 for the earliest version we know the syscall is available.  */
>   Arun> #if __LINUX_KERNEL_VERSION >= 132097
>   Arun> # define __ASSUME_GETDENTS64_SYSCALL    1
>   Arun> #endif
> 
> If you muck with this, it'd probably be best to put it in fs/compat.c
> at the same time.
> 

I've done some more debugging on this and I think there is no problem
with getdents/getdents64.

The problem was with a test case that did pwrite(2) with offset = -1
and it was expecting the test to fail. However, on IA-64, the test
case passed, leaving this temp file on the disk:

$ ls -l /tmp/pwrbcneW5/pwrite_file 
-rw-r--r--    1 tester tester 4294968319 Jan  2 15:34 /tmp/pwrbcneW5/pwrite_file

Subsequently, the test harness tries to cleanup the file and does a
lstat on it, which results in EOVERFLOW.

I'll follow up separately on the other two issues I raised.

        -Arun


