From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Thu, 04 Jul 2002 13:42:05 +0000
Subject: [Linux-ia64] RE: kernel update (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905738@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205855@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205855@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks for your answers.

Kernel is compiled with gcc 3.1 (that should explain the problem of
missing ex-handler in the bundle).

If you need more infos about ltp test suite, you can ask Jacky Malcles(Jacky.Malcles@bull.net).
Thanks
Xavier
------------------------------------------------------------------
test for  Problem 1 (missing EX handler)

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/signal.h>
#include <sys/ioctl.h>
#include <errno.h>


main()
{
  int	s, sinlen;
  s = socket(PF_INET, SOCK_STREAM, 0);
  if (s <0)
    perror("socket");
  getsockname(s, (struct sockaddr *)0, &sinlen);
  perror("getsockname");
}
------------------------------------------------------------------
test for Problem 2(recursive call to __copy_user)

# include <sys/types.h>
# include <sys/ipc.h>
# include <sys/sem.h>
main()
{
  int rc, semid;


  if ((semid=semget(IPC_PRIVATE, 10, IPC_CREAT | IPC_EXCL | 0600 )) = -1) {
    perror("semget");
    exit(2);
  }
  rc=semctl(semid, 0x0, 0xd, 0xffffffffUL);
  perror("semctl");
}
------------------------------------------------------------------

David Mosberger writes:
 > Ken,
 > 
 > >>>>> On Wed, 3 Jul 2002 09:33:35 -0700 , "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:
 > 
 >   Ken> Xavier, Wondering if you can extract the test cases out of your
 >   Ken> test suite and send to me?  The first one is intended not to
 >   Ken> expand the exception marcro due to instruction bundling issue.
 > 
 > Note that with gcc3, tags instead of labels are used to delineate
 > exception regions.  Thus, you shouldn't have to worry about bundling
 > any longer.
 > 
 > 	--david

Chen, Kenneth W writes:
 > Xavier,
 > Wondering if you can extract the test cases out of your test suite and send
 > to me?  The first one is intended not to expand the exception marcro due to
 > instruction bundling issue.  The exception handler suppose to catch the
 > fault.  I would like to see a test case that make it fail.  Thanks.
 > 
 > - Ken
 

