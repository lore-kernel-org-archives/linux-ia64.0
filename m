From: Mario Smarduch <cms063@email.mot.com>
Date: Tue, 04 May 2004 18:12:21 +0000
Subject: Re: mmap() of /dev/kmem issue
Message-Id: <4097DD05.C082320E@email.mot.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4097C51D.71EA0BEA@email.mot.com>
In-Reply-To: <4097C51D.71EA0BEA@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas wrote:

> On Tuesday 04 May 2004 10:30 am, Mario Smarduch wrote:
> > I have problem of viewing memory contents via mmap()
> > of /dev/kmem.
> > ...
> > Any ideas what the problem could be?
>
> Can you post a test case?  What kernel are you running?

To run the test first verify the PAGE_MASK matches. Secondly
compile tstmmapkmem.c, and run runtval.sh it expects an upto date
/boot/System.map file. It seems like the region doesn't appear to
be mapped cachable.

runtval.sh
-------

#!/bin/ksh

jiffies=0x`grep "D jiffies" /boot/System.map | awk '{ print $1 }'`
./tstmmapkmem $jiffies

tstmmapkmem.c - cc -o tstmmapkmem tstmmapkmem.c
----------
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <libgen.h>
#include <sys/time.h>
#include <stdlib.h>
#include <sys/mman.h>

#define IDENBASE 0xe000000000000000
#define DEVICE   "/dev/kmem"
#define PAGE_MASK (0x4000 - 1) /* page is 16k */

#define wmb() __asm__ __volatile__ ("": : :"memory")

extern int errno;
main(int argc, char *argv[])
{
   int fd;
   ulong mapaddr;
   volatile long *jifptr, jiffies;

   jiffies = strtoul(argv[1], 0, 16);
   printf("jiffies = 0x%lx+AFw-n", jiffies);
   printf("pid = %d+AFw-n", getpid());

   if((fd = open(DEVICE, O_RDWR)) < 0)
        printf("open failed - errno = %d+AFw-n", errno), exit(errno);

   jiffies -= IDENBASE;
   mapaddr=(ulong) mmap((void *)0x2000000080000000, 0x8000000,
PROT_WRITE|PROT_R
EAD|PROT_EXEC, MAP_SHARED | MAP_FIXED, fd, jiffies & +AH4-PAGE_MASK);
   if(mapaddr = -1UL) {
      printf("mmap failed errno = %d+AFw-n", errno);
      exit(-1);
   }
   printf("mapaddr = 0x%lx+AFw-n", mapaddr);
   jiffies = mapaddr +- (jiffies & PAGE_MASK);
   jifptr = (long *) jiffies;
   printf("jifptr = 0x%lx+AFw-n", jifptr);
pragain:
   printf("jiffies: %ld+AFw-n",  *jifptr);

   printf("Type return to read again (and flush cashe in meantime):+AFw-n");

   getchar();
   goto pragain;
}

- Mario.

