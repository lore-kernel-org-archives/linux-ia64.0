From: Keith Owens <kaos@sgi.com>
Date: Mon, 24 Feb 2003 23:15:50 +0000
Subject: [Linux-ia64] Re: Bug: Blocking of RT signals in a pause()
Message-Id: <marc-linux-ia64-105590709805924@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805909@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805909@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 21 Feb 2003 17:38:24 +0100, 
Eric Piel <Eric.Piel@Bull.Net> wrote:
>Basically the problem is that while my program is in a pause() I can not
>receive any signal > 32 (RT signals) even if I've just unblocked them.
>In addition if I unblock signal 32 then all the RT signals are
>unblocked. This strange behaviour is not reproductible during a sleep().
>No idea came to my mind to test other system calls so I can't say more.

It looks like this has been fixed in glibc CVS 2003-02-23.  The old
pause file (sysdeps/unix/common/pause.c) has been deleted and
sysdeps/posix/pause.c has been added, containing:

#include <signal.h>
#include <unistd.h>

/* Suspend the process until a signal arrives.
   This always returns -1 and sets errno to EINTR.  */
int
__libc_pause (void)
{
  sigset_t set;

  __sigemptyset (&set);
  __sigprocmask (SIG_BLOCK, NULL, &set);

  /* pause is a cancellation point, but so is sigsuspend.
     So no need for anything special here.  */

  return __sigsuspend (&set);
}
weak_alias (__libc_pause, pause)

Either upgrade ia64 to glibc from CVS or modify your existing glibc to
use the above code for pause.


