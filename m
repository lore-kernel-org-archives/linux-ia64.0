From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 05 Mar 2002 19:44:20 +0000
Subject: RE: [Linux-ia64] Fix for for memory leak in IA32 mmap
Message-Id: <marc-linux-ia64-105590701905227@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905222@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905222@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm not sure that you really need a list ... in fact if you have
a list, I think that I can still come up with pathalogical programs
that will break:  E.g. I might use several mmap() calls to set up
some blocks of memory, but clear them all with one call to munmap()
that spans them all, or I might not do any munmap() at all and
just mmap(MAP_FIXED) things onto the same addresses (since mmap will
throw away existing mappings before creating new ones). Just using
the bitmap to determine whether to round up the end (and round down
the start) address of munmap() requests based on whether the partial
pages have been used should solve most of the problems.

IA-32 programs are limited to the bottom 4G of address space, and
they believe that it is divided into 2^20 * 4KB pages.  A bitmap
for the whole of that would be 128KB, which might be somewhat high
of an overhead for every IA-32 program ... but a two-level table
would most likely be very sparsely filled, limiting the memory
overhead to something acceptable.

Even with this change, there will still be programs that can only
work correctly with a 4k kernel pagesize (e.g. a program that maps
a 4K page from two different files, read+write into the same 16K page)

-Tony

P.S.  Here is a C program that performs the same mmap/munmap operations
in the same order as our nasty Fortran program:

#include <sys/mman.h>

main()
{
        void *a, *b, *c;
        int i;


        for (i = 0; i < 1000; i++) {
                a = mmap(0, 0x201000, PROT_READ|PROT_WRITE,
                        MAP_SHARED|MAP_ANONYMOUS, -1, 0);
                b = mmap(0, 0x101000, PROT_READ|PROT_WRITE, 
                        MAP_SHARED|MAP_ANONYMOUS, -1, 0);
                c = mmap(0, 0x101000, PROT_READ|PROT_WRITE, 
                        MAP_SHARED|MAP_ANONYMOUS, -1, 0);
                if ((long)a = -1 || (long)b = -1 || (long)c = -1)
                        abort();

                munmap(a, 0x201000);
                munmap(b, 0x101000);
                munmap(c, 0x101000);
        }

        return 0;
}



-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
Sent: Tuesday, March 05, 2002 10:59 AM
To: Don Dugger
Cc: davidm@hpl.hp.com; linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] Fix for for memory leak in IA32 mmap


>>>>> On Tue, 5 Mar 2002 10:46:29 -0700, Don Dugger <n0ano@n0ano.com> said:

  Don> David- Yep, it was a virtual memory leak.  Intel came up with a
  Don> Fortran program that was allocating and freeing lots of
  Don> anonymous `mmap's.  It was really nasty because it wasn't even
  Don> the same request all the time, it had something like 3
  Don> different odd size requests that it was `mmap'ing and
  Don> `munmap'ing, all in a loop and eventually it ran out of VM.

OK, thanks for the background.

  Don> I like the idea of keeping a bitmap.  I still have to keep a
  Don> list, it'll actually be a bigger list since I'll have to keep
  Don> track of fixed requests also, but that should handle ALL cases
  Don> (even the case where a program makes an odd sized non-fixed
  Don> `mmap' followed by a fixed `mmap' into the middle of the last
  Don> page).  Give me a few days and I'll see if I can't come up with
  Don> something.

Yes, I agree: the list is still needed and an entry needs to be
created whenever an ia64 page is partially mapped.

Thanks,

	--david

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

