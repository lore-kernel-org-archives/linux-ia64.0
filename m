From: "Hoeflinger, Jay P" <jay.p.hoeflinger@intel.com>
Date: Fri, 22 Feb 2002 15:58:31 +0000
Subject: RE: [Linux-ia64] determining read or write on a page fault
Message-Id: <marc-linux-ia64-105590701905168@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905163@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905163@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hans Boehm writes:

 > According to David Mosberger, there is currently no way to distinguish
 > between a read and a write fault.  This is nontrivial to change because a
 > SIGSEGV is sometimes generated in cases in which it is not clear which
would
 > be appropriate.

Decoding the instruction seems really messy, but maybe I am
not familiar enough with the Itanium architecture.  Apparently
the PC points to an instruction bundle and memory instructions
can appear in both slots 0 and 1, meaning you have to do more than
just determining whether a single instruction was a load or a store.

What if one slot has a load and the other a store?  In that case you
have to resort to matching the address with the address computed
in the instruction, which can be in a register, but I don't know how 
to determine whether the current register contents are valid, or 
whether I have to find the register save area where the value was
saved at the time of the fault.  Additionally, there could be an
immediate value that is added to the register contents, so the 
decoder code must compute the same address that the instruction 
computed before it can compare that to the address passed in sigcontext.

All of this sounds do-able, but it will take time to make sure the
code mimics the address computation precisely.

What isn't do-able is to handle currently undefined op-codes.  This 
means that when new instructions are added, existing binaries break and
we have to revise the decoder.

In looking at the kernel page-fault code, we see that the memory access type
is known at the time of signal dispatch, but then not passed through to the 
user's signal handler.  Couldn't the kernel just pass the access type
in sigcontext (this is how it was done in IA32)?  In the event that 
the access type is not appropriate, then the access type could be 
tagged UNKNOWN.  

It seems that this change to the page-fault code would be practically 
free since the information is already available, and it would save us
(and others) from writing a difficult instruction-decoder that will 
break as soon as a new instruction is added to IPF.

Comments?

Jay

Jay Hoeflinger, jay.p.hoeflinger@intel.com
KAI Software, A Division of Intel Americas, Inc., http://www.kai.com
Phone 217/356-2288, Direct 217/356-5052 x 140, Fax 217/356-5199



-----Original Message-----
From: Boehm, Hans [mailto:hans_boehm@hp.com]
Sent: Thursday, February 21, 2002 3:58 PM
To: 'Hoeflinger, Jay P'; 'linux-ia64@linuxia64.org'
Subject: RE: [Linux-ia64] determining read or write on a page fault


The code for retrieving the address is identical to what I use in our
garbage collector.

According to David Mosberger, there is currently no way to distinguish
between a read and a write fault.  This is nontrivial to change because a
SIGSEGV is sometimes generated in cases in which it is not clear which would
be appropriate.

I suspect the best solution is to decode the faulting instruction
sufficiently to distinguish loads from stores.  I haven't written that code
for Itanium, but my guess is that it's actually not that hard.  David points
out that this will fail if the code is not readable, e.g. if the fault
occurred in the signal trampoline.  (In any case, you need to deal with page
faults in system calls separately, e.g. by avoiding them.)

Hans

> -----Original Message-----
> From: Hoeflinger, Jay P [mailto:jay.p.hoeflinger@intel.com]
> Sent: Thursday, February 21, 2002 1:10 PM
> To: 'linux-ia64@linuxia64.org'
> Subject: [Linux-ia64] determining read or write on a page fault
> 
> 
> We are writing software that handles page faults on an 
> Itanium system, and
> so have registered a SIGSEGV
> handler.  We think we know how to determine the address being 
> referenced,
> but don't know how to determine
> whether the access was a read or a write.
> 
> We believe that the handler entry point should be:
> 
> void
> segv_handler(
>         int                  sig,
>        siginfo_t *sip, 
>         struct sigcontext *scp)
> 
> and the address of the access therefore should be:
> 
> ((caddr_t)sip->si_addr)
> 
> but how do we determine READ vs WRITE?
> 
> In IA-32 linux, we could check the PF_ERR bit.  Is there an 
> equivalent for
> IA-64?
> 
> Thanks
> 
> Naveen Neelakantam and Jay Hoeflinger
> 
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

