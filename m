From: Keith Owens <kaos@sgi.com>
Date: Fri, 03 Dec 2004 03:30:14 +0000
Subject: memccpy() gives inconsistent results on mmapped files
Message-Id: <9880.1102044614@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Glenn Fowler of ATT reported that memccpy() gives inconsistent results
on mmapped files.  This was reported to SGI, but the bug is ia64
generic, I get the same errors on a vanilla ia64 box.

Glenn's test case follows, it has been tweaked to add a PREFAULT
option.  Prefaulting the input file makes memccpy work.  The problem
occurs on both glibc 2.2.4 and glibc 2.3.3.

# for i in 1 257 513 1025;do cc -DNUM=$i testmemccpy.c; ./a.out; done
FAILED NUM 1 offset 0 size 64 no match
FAILED NUM 257 offset 16384 size 8
OLD xxxxxxxx
NEW xxxxxxxN
FAILED NUM 513 offset 32768 size 8
OLD xxxxxxxx
NEW xxxxxxxN
FAILED NUM 1025 offset 65536 size 8
OLD xxxxxxxx
NEW xxxxxxxN

# for i in 1 257 513 1025;do cc -DNUM=$i -DPREFAULT testmemccpy.c; ./a.out; done
No errors.

/*
 * the umpteenth linux ia64 memccpy indictment
 *
 * Glenn Fowler ATT
 *
 * creates/clobbers the file ./testmemccpy.dat
 *
 * fails with
 *
 *      -DNUM=1 
 *      -DNUM%7
 *      -DNUMQ3
 *      -DNUM25
 *
 * works with -DOH and any -DNUM=n, n>0, n<memory-limit
 *
 * please eradicate the cute memccpy tricks
 * surely the processor is fast enough to minimize their impact
 *
 * Also works with -DPREFAULT - prefaulting the mmapped file gives the
 * correct results in memccpy.  kaos@sgi.com
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#ifndef NUM
#define NUM 257
#endif

#if OH

#undef  memccpy
#define memccpy memccpy_that_works

void* memccpy(void* as1, const void* as2, int c, size_t n)
{
        char*           s1 = (char*)as1;
        const char*     s2 = (char*)as2;
        const char*     ep = s2 + n;

        while (s2 < ep)
                if ((*s1++ = *s2++) = c)
                        return s1;
        return 0;
}

#endif

static const char x[] = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxN";

int main()
{
        char*           b;
        char*           s;
        char*           e;
        char*           t;
        long            m;
        int             f;
        char            u[1024];

        if ((f = open("testmemccpy.dat", O_CREAT|O_RDWR|O_TRUNC, 0666)) < 0)
        {
                fprintf(stderr, "creat error\n");
                return 1;
        }
        for (m = 0; m < NUM; m++)
                if (write(f, x, sizeof(x)-1) != sizeof(x)-1)
                {
                        fprintf(stderr, "write error\n");
                        return 1;
                }
        if (lseek(f, (off_t)0, SEEK_SET))
        {
                fprintf(stderr, "seek error\n");
                return 1;
        }
        m *= (sizeof(x)-1);
        if (!(b = s = mmap((void*)0, m, PROT_READ|PROT_WRITE, MAP_PRIVATE, f, (off_t)0)))
        {
                fprintf(stderr, "mmap error\n");
                return 1;
        }
#ifdef	PREFAULT
	for (s = b; s < b+m; s+@96)
		f = *s;
	s = b;
#endif
        for (e = s + m; s < e && (t = memccpy(u, s, 'N', (e-s) > sizeof(u) ? sizeof(u) : (e-s))); s += (t-u))
                if ((t-u) != (sizeof(x)-1) || memcmp(u, s, t-u))
                {
                        fprintf(stderr, "FAILED NUM %d offset %lu size %lu\n", NUM, (unsigned long)(s-b), (unsigned long)(t-u));
                        fprintf(stderr, "OLD %-.*s\n", t-u, s);
                        fprintf(stderr, "NEW %-.*s\n", t-u, u);
                        return 1;
                }
        if (s < e)
        {
                fprintf(stderr, "FAILED NUM %d offset %lu size %lu no match\n", NUM, (unsigned long)(s-b), (unsigned long)(e-s));
                return 1;
        }
        return 0;
}


