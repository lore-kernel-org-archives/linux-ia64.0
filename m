From: =?windows-1252?Q?Anders=20Herbj=F8rnsen?= <anders.herbjornsen@start.no>
Date: Thu, 04 Apr 2002 11:48:50 +0000
Subject: [Linux-ia64] pipe() not setting errno.
Message-Id: <marc-linux-ia64-105590701905376@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello,

When running out of file descriptors pipe() does return -1 but
errno is not set. This is working ok on IA32 systems, but fails
on IA64. I've tested this with kernels 2.4.9 and 2.4.18.

Below is a small sample program to illustrate the problem:

########################################################
#include <stdio.h>
#include <errno.h>
#include <unistd.h>

int main (int argc, char **argv){
  int i;
  for (i =3D 0; i < 3000; i++) {
    int fd[2];
    if (-1 =3D pipe(fd))
      break;
    printf ("%d ", i);
  } /* for */
  printf ("\npipe number %d error: errno=3D%d\n", i, errno);
  return errno;
}
#############################################################

Sample run:

$ ulimit -n 12
$ ./tpipe
0 1 2 3
pipe number 4 error: errno=3D0

Regards
Anders Herbj=F8rnsen




