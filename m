From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 17 Dec 2002 23:25:38 +0000
Subject: [Linux-ia64] Re: Use of __ia64_syscall() - syscall interface
Message-Id: <marc-linux-ia64-105590709805604@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805572@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805572@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 17 Dec 2002 15:00:49 +0100 (NFT), Joel GUILLET <Joel.Guillet@bull.net> said:

  Joel> Actually, I had seen before some (lots of) mails (many from
  Joel> you) that recommands the use of the syscall() interface, but I
  Joel> mis-understood the message...  The problem is that I got some
  Joel> problems to find documentation about this interface and made a
  Joel> mix between the kernel and the glibc interfaces.  (I finally
  Joel> found some in glibc/manual/libc.info-43 )

Yes, syscall() is documented in the glibc manual.

  Joel> #ifndef __NR_sched_setaffinity
  Joel> #ifndef _AFFINITY_H
  Joel> #define _AFFINITY_H

  Joel> #if defined(__ia64__)
  Joel> #define __NR_sched_setaffinity 1231
  Joel> #define __NR_sched_getaffinity 1232
  Joel> #endif

  Joel> #define sched_setaffinity(arg1, arg2, arg3) syscall(__NR_sched_setaffinity, arg1, arg2, arg3)
  Joel> #define sched_getaffinity(arg1, arg2, arg3) syscall(__NR_sched_getaffinity, arg1, arg2, arg3)

  Joel> #endif /* __NR_sched_setaffinity */
  Joel> #endif /* _AFFINITY_H */

This is basically fine, except that for syscall(), the syscall number macros
by convention start with SYS_*.  So I'd rewrite your code to:

#ifndef SYS_sched_setaffinity
#ifndef _AFFINITY_H
#define _AFFINITY_H

#if defined(__ia64__)
#define SYS_sched_setaffinity 1231
#define SYS_sched_getaffinity 1232
#endif

#define sched_setaffinity(arg1, arg2, arg3) syscall(SYS_sched_setaffinity, arg1, arg2, arg3)
#define sched_getaffinity(arg1, arg2, arg3) syscall(SYS_sched_getaffinity, arg1, arg2, arg3)

#endif /* SYS_sched_setaffinity */
#endif /* _AFFINITY_H */

	--david

