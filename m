From: Shaun <delius@progsoc.uts.edu.au>
Date: Mon, 08 Mar 2004 23:43:45 +0000
Subject: Virtual memory leaking through IA32 emulation layer for mmap and
Message-Id: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,

I'm not sure if this is a known issue or not, but we have been having some
trouble running some of our programs under the IA32 emulation layer of
linux-ia64.

What is happening in our case is that our program is indirectly causing
lots of mmaps of anonymous memory for 4096 bytes. Shortly thereafter these
blocks are munmaped. The munmap is effectively ignored causing the program
to leak a page (16K in our kernel) of virtual memory.

The situation can be illustrated with the following code when compiled on
an IA32 system then run on a IA64 system:

for (int i = 0; i < 10000; i++)
{
   pvAddr = mmap(NULL, getpagesize(), PROT_READ|PROT_WRITE,
                 MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
   printf("%p\n", pvAddr);
   munmap(pvAddr, getpagesize());
}

Given that getpagesize() is hardcoded in glibc it returns 4096, the mmap
succeeds and the compatibility layers actually allocate a full page (the
kernel in question has PAGE_SHIFT set to 14 for a page size of 16K).
However the munmap hits the following bit of code in sys_ia32.c:

asmlinkage long
sys32_munmap (unsigned int start, unsigned int len)
{
   unsigned int end = start + len;
   long ret;
...
   start = PAGE_ALIGN(start);
   end = PAGE_START(end);

   if (start >= end)
      return 0;

Because end is always less than a page size away from start, start and end
are equal causing munmap to return 0 without doing anything (leaking
memory).

The most obvious solution to this in userland is using the correct page
size, which is what we have done inside our product (we determine it at
run time). Unfortunately, the memory we're leaking now is being leaked by
the glibc standard io routines. They hardcode the page size as 4k and use
mmap to allocate a buffer big enough for the first fgets and fputs on a
stream. Since we use a lot of streams, we leak quickly.

Unfortunately, even avoiding streams won't really save us from this
problem since any other routine we use could well perform mmaps of this
type under the covers now or in the future.

Does anyone have any suggestions for how this could/should be fixed kernel
wise?  We're happy to implement what we can and contribute the changes
back.

Thanks,
Shaun



