From: "Hoeflinger, Jay P" <jay.p.hoeflinger@intel.com>
Date: Fri, 07 Dec 2001 14:53:14 +0000
Subject: RE: [Linux-ia64] mprotect problem
Message-Id: <marc-linux-ia64-105590698805639@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805634@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805634@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

No, we haven't checked that this is not a page size or alignment issue.
The page size we get from getpagesize().

The alignment we get from the following:

			if ((shmid = shmget(IPC_PRIVATE, len,
IPC_CREAT|0600)) < 0)
				Tmk_perrexit("Tmk_page_initialize<shmget>:
can't allocate the shared memory");

			if ((page->vadr = shmat(shmid, addr, 0)) =
(caddr_t) -1L)
				Tmk_perrexit("Tmk_page_initialize<shmat>:
can't map the shared memory");

page->vadr is the address of the base of the area that we are managing
via our distributed shared virtual memory mechanism (the address of page 0.

We then attempt to open a swap file and mmap the whole range of addresses we
will manage (the length is "len"), map a set of alias pages, then mprotect 
the non-alias portion either PROT_READ or no-access.

			if ((fd = open(name, O_RDWR|O_CREAT|O_TRUNC, 0600))
< 0)
				Tmk_perrexit("Tmk_page_initialize<open>:
open(\"%s\", ... )", name);
			
			if (0 > unlink(name))
				Tmk_perrexit("Tmk_page_initialize<unlink>");

			if ((len - sizeof(c)) != lseek(fd, len - sizeof(c),
SEEK_END))
				Tmk_perrexit("Tmk_page_initialize<lseek>");

			if (0 > write(fd, &c, sizeof(c)))
				Tmk_perrexit("Tmk_page_initialize<write>");
#else
			if ((fd = open("/dev/zero", O_RDWR)) = -1)
				flags |= MAP_ANONYMOUS;
			else
				flags |= MAP_FILE;
#endif
			if ((page->vadr = mmap(addr, len, prot, flags, fd,
0)) = (caddr_t) -1L)
				Tmk_perrexit("Tmk_page_initialize<mmap>:
can't allocate the shared memory");

			if ((page->v_alias = mmap(addr+2*len, len, prot,
flags&~MAP_FIXED, fd, 0)) = (caddr_t) -1L)
				Tmk_perrexit("Tmk_page_initialize<mmap>:
can't allocate the shared memory");

			if (fd != -1)
				close(fd);
#endif
			if (Tmk_page_init_to_valid) {

				if (Tmk_nprocs > 1)
					if (0 > mprotect(page->vadr, len,
PROT_READ))
	
Tmk_perrexit("Tmk_page_initialize<mprotect>");
			}
			else {
				if (Tmk_proc_id)
					if (0 > mprotect(page->vadr, len,
0))
	
Tmk_perrexit("Tmk_page_initialize<mprotect>");
			}

We compute the address of the rest of the pages by looping and successively
adding the page size to this address.

This part seems to work, since we see the original fault happening as it
should,
but once this initial protection is set up, we seem to be unable to change
it,
even though we use:

				if (0 > mprotect(page->vadr, Tmk_page_size,
PROT_READ|PROT_WRITE))
	
Tmk_perrexit("segv_handler<mprotect>");

Also, as I said before, this is on a dual-processor Itanium box.  Currently
we are 
running two processes, both on the same box, that are cooperating to do this

DVSM operation.

Any ideas?

Jay

-----Original Message-----
From: Boehm, Hans [mailto:hans_boehm@hp.com]
Sent: Thursday, December 06, 2001 6:20 PM
To: 'Hoeflinger, Jay P'
Cc: 'n0ano@indstorage.com'; MOSBERGER, DAVID (HP-PaloAlto,unix3)
Subject: RE: [Linux-ia64] mprotect problem


I assume you checked that this is not a page size or alignment issue?

My garbage collector does something very similar when running in incremental
mode.  The standard test consistently passes on Itanium.  There are some
differences:  It only write protects pages.  It immediately unprotects the
page, and does little else, in the signal handler.  And of course the timing
is all different.  It's running in native IA64 mode.

Hans

> -----Original Message-----
> From: Hoeflinger, Jay P [mailto:jay.p.hoeflinger@intel.com]
> Sent: Thursday, December 06, 2001 3:56 PM
> To: 'linux-ia64@linuxia64.org'
> Subject: [Linux-ia64] mprotect problem
> 
> 
> We are seeing an apparent problem with mprotect on Itanium.  
> We have seen
> the problem
> on two different machines, one running RedHat 7.1 (Seawolf)  
> [2.4.3-12smp]
> and one
> running Turbolinux [2.4.1-010131-8smp].
> 
> The mprotect is called from user space, as part of the 
> implementation of a 
> distributed virtual shared memory system that uses the virtual
> memory mechanism to implement a shared address space between 
> two or more
> nodes.
> 
> The code works correctly under RedHat 7.1 for IA32 (and a 
> variety of other
> OS'es and platforms, so
> we feel that there aren't coding errors, although maybe there is some
> slightly different
> way to use mprotect on Itanium (additional parameters, or flags?)?.
> 
> The problem we see is this:
> 
> During the course of running the user's program on top of our 
> DVSM, the
> program touches 
> a "shared" page that has been mprotect'ed against reading and writing
> previously because it is not
> up-to-date with respect to the same page on other nodes in 
> the system.  The
> access faults,
> our SEGV handler is called, we do the appropriate message 
> passing operations
> to 
> make the data on the page consistent and up-to-date, then do 
> an mprotect
> allowing 
> READ and WRITE this time, and return from the SEGV handler.  
> At this point,
> the original instruction
> (a READ) is restarted and immediately faults, causing control 
> to go to the
> SEGV handler 
> again.  This time, since we know the page is up-to-date, we 
> do nothing and
> return, the 
> instruction is again re-started, again faults, again jumps to the SEGV
> handler . . . an infinite
> loop.
> 
> The interesting thing is that this particular user code fails 
> at random
> points, sometimes working
> correctly at points where it failed before.  We have never 
> seen the code
> work correctly all the way
> through, though.  It always fails very soon after it begins, just at
> different points on different runs.
> We theorized that this was a timing problem, such that it 
> just took some
> time for mprotect to 
> take effect, so we put in 10-millisecond delays after each 
> mprotect, but
> this really changed nothing.
> 
> One potential clue would be that the code is a pthreads program, and
> multiple threads are 
> running while one thread is doing the mprotect, and these 
> machines are both
> dual-processor machines.
> 
> We would appreciate any help that anyone can give.
> 
> Jay
> 
> Jay Hoeflinger, jay.p.hoeflinger@intel.com
> KAI Software, A Division of Intel Americas, Inc., http://www.kai.com
> Phone 217/356-2288, Direct 217/356-5052 x 140, Fax 217/356-5199
> 
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

