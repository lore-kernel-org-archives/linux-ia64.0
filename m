From: Richard Hirst <rhirst@linuxcare.com>
Date: Tue, 16 Apr 2002 20:00:09 +0000
Subject: [Linux-ia64] gcc type promotion bug?
Message-Id: <marc-linux-ia64-105590701905457@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

#include <stdio.h>

int
main(int argc, char **argv)
{
        long a = 0x70000037L;
        float f = 0.01;
        long b = a + 1L/f;

        printf("%lx, %lx\n", b, a + 100L);
        return 0;
}



In the above, 1/f = 100, so the two numbers printed out should be the
same.  For me it prints out "70000080, 7000009b".  Same for gcc 2.96
and 3.0.3.

By trying various numbers for 'a', it appears to me that it is demoting
'a' to a float when evaluating 'b', thus truncating it to 24 significant
bits.  I thought all mixed mode arithmetic was supposed to be promoted
to doubles for evaluation.  This is breaking parted 1.6 on ia64.

Richard


