From: Jacky Malcles <Jacky.Malcles@bull.net>
Date: Wed, 28 Aug 2002 12:09:34 +0000
Subject: [Linux-ia64] How do I enable direct IOs with ia64 ?
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------9E6BEA58C6E7C4D49F591492"
Message-Id: <marc-linux-ia64-105590701905991@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------9E6BEA58C6E7C4D49F591492
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

If I run the following piece of code to an ia64 (azusa) I can see that
direct
io are not enabled, but please,
what do i have to do to have them running? 

remark: With ia32, this code works fine and I directly get:
------
"test:  completed" and the file "infile" is initialized

with ia64, it does not work and I get:
"write infile failed: Invalid argument"
... and the file "infile" is not filled up.

version:
Linux version 2.4.18 (xb@pegtst2) (gcc version 3.1) #8 SMP Wed Aug 7
14:30:09
CEST 2002

compil:
cc -O  -D_GNU_SOURCE voyons.c   -o voyons
--------------9E6BEA58C6E7C4D49F591492
Content-Type: text/plain; charset=us-ascii;
 name="voyons.c"
Content-Disposition: inline;
 filename="voyons.c"
Content-Transfer-Encoding: 7bit

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <sys/fcntl.h>
#include <errno.h>

#define BUFSIZE 8192
#define NBLKS   20
#define LEN     30
#define TRUE 1
void
fillbuf(char *buf, int count, char value)
{
        while (count-- > 0) *buf++ = value;
}


int
main(int argc, char *argv[])
{
        int     bufsize = BUFSIZE;      /* Buffer size. Default 8k */
        int     numblks = NBLKS;        /* Number of blocks. Default 20 */
        char    infile[LEN];            /* Input file. Default "infile" */
        int     fd1, fd2;
        int     i, n, offset;
        char    *buf;

        strcpy(infile, "infile");       /* Default input file */
        if ((fd1 = open(infile, O_DIRECT|O_RDWR|O_CREAT, 0666)) < 0) {
                fprintf(stderr, "open infile: %s\n", strerror(errno));
                exit(1);
        }

        /* Allocate for buf, Create input file */
        if ((buf = valloc(bufsize)) == 0) {
                fprintf(stderr, "valloc buf: %s\n", strerror(errno));
        }

        for (i = 0; i < numblks; i++) {
                fillbuf(buf, bufsize, 'Z');
                if (write(fd1, buf, bufsize) == -1) {
                        fprintf(stderr, "write infile failed: %s\n",
                                strerror(errno));
                }
        }
        fprintf(stdout, "test:  completed\n");
        exit(0);

}


--------------9E6BEA58C6E7C4D49F591492--


