From: n0ano@indstorage.com
Date: Fri, 22 Feb 2002 17:29:16 +0000
Subject: Re: [Linux-ia64] determining read or write on a page fault
Message-Id: <marc-linux-ia64-105590701905173@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905163@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905163@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jay-

Check out the unaligned fault handler in `arch/ia64/kernel/unaligned.c'
That code should show you what you need to do.

On Fri, Feb 22, 2002 at 09:27:15AM -0800, Hoeflinger, Jay P wrote:
> So the slot number is in sigcontext!  That makes things considerably
> easier.  Does anyone have a piece of code that determines whether 
> a given instruction is a load or a store?
> 
> Jay
> 
> -----Original Message-----
> From: David Mosberger [mailto:davidm@hpl.hp.com]
> Sent: Friday, February 22, 2002 11:06 AM
> To: Hoeflinger, Jay P
> Cc: 'Boehm, Hans'; 'linux-ia64@linuxia64.org'
> Subject: RE: [Linux-ia64] determining read or write on a page fault
> 
> 
> >>>>> On Fri, 22 Feb 2002 07:58:31 -0800, "Hoeflinger, Jay P"
> <jay.p.hoeflinger@intel.com> said:
> 
>   Jay> Decoding the instruction seems really messy, but maybe I am not
>   Jay> familiar enough with the Itanium architecture.
> 
> It shouldn't be that bad.  For a DSM, you only need to be able to
> reliably detect stores (everything else you can just assume to be
> loads).
> 
>   Jay> Apparently the
>   Jay> PC points to an instruction bundle and memory instructions can
>   Jay> appear in both slots 0 and 1, meaning you have to do more than
>   Jay> just determining whether a single instruction was a load or a
>   Jay> store.
> 
> Bits 0 and 1 in the IP stored in the sigcontext (sc_ip) encode the
> slot number 0, so you'll know exactly which instruction caused the
> fault.
> 
>   Jay> What if one slot has a load and the other a store?  In that
>   Jay> case you have to resort to matching the address with the
>   Jay> address computed in the instruction, which can be in a
>   Jay> register, but I don't know how to determine whether the current
>   Jay> register contents are valid, or whether I have to find the
>   Jay> register save area where the value was saved at the time of the
>   Jay> fault.  Additionally, there could be an immediate value that is
>   Jay> added to the register contents, so the decoder code must
>   Jay> compute the same address that the instruction computed before
>   Jay> it can compare that to the address passed in sigcontext.
> 
> None of that should be necessary.
> 
>   Jay> All of this sounds do-able, but it will take time to make sure
>   Jay> the code mimics the address computation precisely.
> 
>   Jay> What isn't do-able is to handle currently undefined op-codes.
>   Jay> This means that when new instructions are added, existing
>   Jay> binaries break and we have to revise the decoder.
> 
>   Jay> In looking at the kernel page-fault code, we see that the
>   Jay> memory access type is known at the time of signal dispatch, but
>   Jay> then not passed through to the user's signal handler.  Couldn't
>   Jay> the kernel just pass the access type in sigcontext (this is how
>   Jay> it was done in IA32)?  In the event that the access type is not
>   Jay> appropriate, then the access type could be tagged UNKNOWN.
> 
> Yes, we can do that and I'm planning to make such a change.  The solution
> Hans proposed is what you'd have to do if you need things working with
> today's kernels.
> 
> If you're willing to wait for a new kernel, I can send you a patch
> that adds the extra info to siginfo.
> 
>   Jay> It seems that this change to the page-fault code would be
>   Jay> practically free since the information is already available,
>   Jay> and it would save us (and others) from writing a difficult
>   Jay> instruction-decoder that will break as soon as a new
>   Jay> instruction is added to IPF.
> 
> Yes, clearly that's preferable in the longer term.  Nobody is
> objecting to doing this, it's just that nobody has gotten around to
> implementing it so far.
> 
> 	--david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

