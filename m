From: Trent Mick <trentm@activestate.com>
Date: Mon, 01 May 2000 18:43:59 +0000
Subject: [Linux-ia64] bug in fmod on trillian [fmod(-10,1) causes core dump]
Message-Id: <marc-linux-ia64-105590678205058@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I hope that someone appropriate (i.e. someone at Cygnus or someone on
ia64-tools) sees this message.

Some arguments to fmod() cause a segmentation fault on trillian. Examples are
fmod(-10,1), fmod(-10,0.5).


Here is a test case:

-----------> ls
Makefile  fmodbug.c
-----------> cat fmodbug.c
#include <stdio.h>
#include <math.h>

int main(void)
{
        int i;
        double d;

        d = fmod(-10.0, 1.0);
        printf("fmod(-10,1) = %f\n", d);

        return 0;
}
-----------> cat Makefile
all : fmodbug

fmodbug : fmodbug.c
        gcc -lm fmodbug.c -o fmodbug

test :
        ./fmodbug

clean :
        -rm -f fmodbug
        -rm -f core
        -rm -f *~
-----------> make
gcc -lm fmodbug.c -o fmodbug
-----------> make test
./fmodbug
make: *** [test] Segmentation fault (core dumped)
----------->


I would appreciate a reply if this reaches the proper eyes. Or, if someone
can tell me to whom this should properly reported...

Thanks,
Trent

--
Trent Mick
trentm@activestate.com



