From: "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp>
Date: Wed, 14 Nov 2001 06:53:58 +0000
Subject: Re: [Linux-ia64] Pagesize is different between IA32 and IA64
Message-Id: <marc-linux-ia64-105590698805503@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805465@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805465@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 Hi Don.

 Yes, you are correct. 

 If my test program is run on IA64 system(not IA32
 simulation), you should change the size from 4K to
 16K. because the pagesize on IA64 is 16K. And I have
 heard if I use the sbrk function directly, The
 paramater for srbk must be the pagesize on running
 machine(except simulated machine, as a IA32 on IA64).

 Please confirm the return value from __getpagesize
 function.

    main() {
        printf("0x%x\n", __getpagesize());
    }

 BTW, calloc is included in malloc.c.
 You would like to open the file glibc-2.2.4/malloc/malloc.c,
 and then you will be looking for cALLOc. It is calloc function.
 
At Tue, 13 Nov 2001 23:16:09 -0700,
Dugger's wrote:
> 
> I'm a little confused.  From Hideki's test program the problem actually
> seems
> to be using `sbrk' to return memory and then allocating memory again.  The
> second
> time the re-allocated memory is not zeroed, e.g.:
> 
>     p = sbrk(4096);
>     q = sbrk(-4096);
>     r = sbrk(4096);
> 
> and the memory pointed to by `r' is not zeroed.  I just got through reading
> the
> man page for `brk' and `sbrk' and neither one specifies that newly allocated
> memory is zeroed and therefore I interpret this issue as undefined behavior.
> Any program that depends upon the contents of newly allocated memory is
> broken.  In fact, if you compile the test program, `d.c', for IA64 and run
> it it
> fails.  Also, if you compile the test program for IA32 and use 1K allocation
> blocks
> the program fails on an IA32 machine also.
> 
> Someone correct me if I'm wrong about this.
> 
> PS:  I know that `calloc' is defined to zero out the allocated memory but
> from
> what I can tell it does this by explicitly calling `memset'.  I'm trying to
> verify this
> but I haven't found the `calloc' code in the `glibc' tree yet.  (The `glibc'
> tree always
> confuses me, if anyone can tell me exactly where to find the `calloc' code
> I'd
> appreciate it :-)
> --
> Don Dugger
> n0ano@indstorage.com
> ----- Original Message -----
> From: "David Mosberger" <davidm@hpl.hp.com>
> To: <n0ano@indstorage.com>
> Cc: "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp>;
> <linux-ia64@linuxia64.org>
> Sent: Monday, November 12, 2001 4:58 PM
> Subject: Re: [Linux-ia64] Pagesize is different between IA32 and IA64
> 
> 
> > But I think the page size problem with brk() is real and can be fixed
> > quite easily.  If I understood correctly, the problem is that doing
> > something along the lines of:
> >
> > x = ALIGN_TO_4K(sbrk(8192));
> > memset(x, 0xff, 4096);
> > brk(x);
> > brk(x+4096);
> >
> > might preserve the contents of the page at X on under the ia32
> > subsystem of ia64 when in fact it should be cleared to zero.
> >
> > Would you be able/interested into looking into this?
> >
> > --david
> >
> 

