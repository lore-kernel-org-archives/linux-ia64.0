From: "Boehm, Hans" <hans_boehm@hp.com>
Date: Fri, 07 Dec 2001 20:13:26 +0000
Subject: RE: [Linux-ia64] mprotect problem
Message-Id: <marc-linux-ia64-105590698805649@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805634@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805634@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

What's the instruction that's faulting and what are the contents of the
register used for addressing?  You should easily be able to get that out of
gdb.

I assume the printf in the handler is using an incorrect (32 bit int) format
to print the address.  It should be using something like %p.  That's
probably irrelevant to the real problem.

Hans

> -----Original Message-----
> From: Hoeflinger, Jay P [mailto:jay.p.hoeflinger@intel.com]
> Sent: Friday, December 07, 2001 11:47 AM
> To: 'davidm@hpl.hp.com'; Hoeflinger, Jay P
> Cc: 'Boehm, Hans'; 'n0ano@indstorage.com'; 'linux-ia64@linuxia64.org'
> Subject: RE: [Linux-ia64] mprotect problem
> 
> 
> OK, here's a trace.  The program is multi-threaded, so I used
> strace -f.  Fortunately the problem happens almost right away.
> At the very end, you can see the infinite loop starting.
> One thing I noticed is that our printf's in the segv handler
> are printing the fault
> address as 20004000 while the mprotect is giving the address
> as 6000000020004000.  This last address seems to be correct in 
> relation to the original mprotect for the shared heap, which was
> 
> mprotect(0x6000000020000000, 268435456, PROT_NONE) = 0
> 
> Please let me know if this tells you anything interesting.
> 
> Jay
> 
> -----Original Message-----
> From: David Mosberger [mailto:davidm@hpl.hp.com]
> Sent: Friday, December 07, 2001 11:35 AM
> To: Hoeflinger, Jay P
> Cc: 'Boehm, Hans'; 'n0ano@indstorage.com'; 'linux-ia64@linuxia64.org'
> Subject: RE: [Linux-ia64] mprotect problem
> 
> 
> Jay,
> 
> If you don't have a minimal test program or can't share the source
> code, it might be useful to collect a syscall trace.  That way, we
> could see what addresses and sizes are involved in the mprotect()
> call.  Something like:
> 
> 	strace -o /tmp/out PROGNAME
> 
> should do (I'm assuming your program is not multithreaded; if it is,
> you'd need to use the -f option and make sure you're running the
> latest version of strace).
> 
> If the resulting output is very big, you won't be able to send it to
> the mailing list.  You can either trim the output or just make sure
> you mail it to me directly (davidm@hpl.hp.com).
> 
> Thanks,
> 
> 	--david
> 
> 

