From: Jeff Licquia <licquia@progeny.com>
Date: Wed, 05 Oct 2005 21:43:34 +0000
Subject: [Fwd: Weird ia64 problem]
Message-Id: <1128548614.4623.45.camel@laptop1>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-yPCq0Pz6lENbbcY2guTv"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-yPCq0Pz6lENbbcY2guTv
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

It was suggested to me that this might be of interest outside the LSB,
and that I should forward it more widely...


--=-yPCq0Pz6lENbbcY2guTv
Content-Disposition: inline
Content-Description: Forwarded message - Weird ia64 problem
Content-Type: message/rfc822

Subject: Weird ia64 problem
From: Jeff Licquia <licquia@progeny.com>
To: lsb-test@freestandards.org
Content-Type: multipart/mixed; boundary="=-1XZ3txIWSw28m566hTK1"
Date: Wed, 05 Oct 2005 15:29:25 -0500
Message-Id: <1128544165.4623.39.camel@laptop1>
Mime-Version: 1.0
X-Mailer: Evolution 2.0.4 


--=-1XZ3txIWSw28m566hTK1
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

[It seems I've been using the wrong address for the list, and for some
reason haven't been seeing bounces.  This is a summary of my past
attempts to send to the list.  I apologize if this is a dup, or if my
past messages make their way out of whatever limbo they are stuck in
now.]

I've been seeing some weird test failures on ia64, namely:

/tset/ANSI.os/streamio/fwrite/T.fwrite 3 UNRESOLVED
/tset/LSB.os/ioprim/writev_L/T.writev_L 13 FAIL
/tset/POSIX.os/ioprim/write/T.write 13 FAIL

These all appear to be caused by the same problem: getting EAGAIN on a
non-blocking pipe write when not expected.  At first, I thought it might
just be a test bug, since the behavior is legitimate according to the
spec, but one of the tests (T.fwrite) actually looks specifically for
this condition.  What's weirder: I was seeing these faults on a DCC
system, but not on Debian stable.

I was able to write a standalone test that reproduces the problem.  (The
C source is attached.)  Basically, the tests seem to rely on the ability
of a full pipe to receive more input (and thus unblock) once some of the
data in the pipe is read.  It seems that newer ia64 kernels don't do
this.

On all Debian-based i386 and amd64 systems I've run it on, my test
prints "the write appeared to succeed", which indicated the LSB tests
above should pass.  Running on any ia64 system with the stock Debian
stable kernel (2.6.8) produces the same results.  But running my test on
either the 2.6.12 DCC kernel or the latest 2.6.12 kernel from Debian
unstable prints "the write failed; EAGAIN seen", which corresponds to
the weird results above.

Has anyone else seen this?  My searches for a cause have come up
fruitless so far.  I'm reduced to building kernels 2.6.9 through 2.6.11
to try and find the exact place where the regression was introduced.


--=-1XZ3txIWSw28m566hTK1
Content-Disposition: attachment; filename=test.c
Content-Type: text/x-csrc; name=test.c; charset=UTF-8
Content-Transfer-Encoding: 7bit

#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

int main(int argc, char *argv[])
{
    int pipes[2];
    int flags;
    long pipe_buf;
    size_t bufsize1, bufsize2, nitems;
    FILE *fp;
    char *bp;

    if (pipe(pipes) != 0) {
        fprintf(stderr, "error: could not create pipe\n");
        return 1;
    }

    flags = fcntl(pipes[1], F_GETFL, 0);
    flags |= O_NONBLOCK;
    fcntl(pipes[1], F_SETFL, flags);

    pipe_buf = fpathconf(pipes[1], _PC_PIPE_BUF);
    if (pipe_buf <= 0L) {
        printf("cannot test: unlimited pipe buffer\n");
        return 0;
    }

    bufsize1 = (size_t) pipe_buf + 16;
    bufsize2 = bufsize1 + 8;

    fp = fdopen(pipes[1], "w");
    if (fp == NULL) {
        fprintf(stderr, "error: could not reopen pipe\n");
        return 1;
    }

    setbuf(fp, (char *) NULL);

    bp = (char *) malloc(bufsize2);
    if (bp == NULL) {
        fprintf(stderr, "error: could not allocate memory\n");
        return 1;
    }

    while (write(pipes[1], bp, (unsigned) pipe_buf/2) == pipe_buf/2) ;
    read(pipes[0], bp, (unsigned) pipe_buf);

    /* here we go */
    nitems = fwrite((void *) bp, 1, (size_t) bufsize2, fp);
    if (nitems > 0) {
        printf("the write appeared to succeed\n");
    } else if (ferror(fp)) {
        if (errno == EAGAIN) {
            printf("the write failed; EAGAIN seen\n");
        } else {
            printf("the write failed; error: %s\n", strerror(errno));
        }
    } else {
        printf("something weird happened\n");
    }

    return 0;
}

--=-1XZ3txIWSw28m566hTK1--

--=-yPCq0Pz6lENbbcY2guTv--
