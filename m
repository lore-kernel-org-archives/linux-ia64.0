From: "Dong Wei" <dong_wei@hp.com>
Date: Tue, 31 Jul 2001 18:57:09 +0000
Subject: RE: [Linux-ia64] settings AR.k0 to ia64_iobase is wrong?
Message-Id: <marc-linux-ia64-105590693005970@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005964@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005964@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

AR.k0 contains the virtual address that SAL uses for the IO Port Base.
The SAL spec asks the OSes not to change this value until the IVAs are
taken over. The reason for this is that some implementation of SAL
contains the x86 BIOS code.

The AR.k0 value reported by SAL is of no use to the OSes because it is a
virtual address used by SAL only, not by the OSes. OSes get the physical
IO Port Base from the EFI GetMemoryMap call. 

After the OS gets the physical IO Port base, it should apply the OS
PA-VA mapping.

Regards,

Dong Wei
Systems Architecture
Hewlett Packard
dong_wei@hp.com
(916)748-2461 

> -----Original Message-----
> From: linux-ia64-admin@linuxia64.org 
> [mailto:linux-ia64-admin@linuxia64.org] On Behalf Of David Mosberger
> Sent: Tuesday, July 31, 2001 11:06 AM
> To: nomura@hpc.bs1.fc.nec.co.jp
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] settings AR.k0 to ia64_iobase is wrong?
> 
> 
> >>>>> On Tue, 31 Jul 2001 19:06:28 +0900, 
> nomura@hpc.bs1.fc.nec.co.jp said:
> 
>   >> This isn't right.  There is no way a VA->PA translation can set
>   >> bit 63 so address 0x80000ffffc000000 could only be generated in
>   >> physical mode, which Linux (almost) never uses.  The address
>   >> 0xffffc000000 is correct since Linux will access the memory range
>   >> only through uncached space (region 6).
> 
>   Nomura> I didn't talk about VA-PA translation nor I/O memory range
>   Nomura> access by linux.  'mapping' was the wrong word, I'm afraid.
> 
> What I'm saying is that an address with bit 63 set is not a proper
> physical address (it's nothing that will ever show up on the physical
> address bus) and therefore cannot be addressed using virtual
> addressing.  Thus, such an address is useless for Linux.
> 
>   Nomura> I mean ar.k0 seems to be used by SAL in physical mode and
>   Nomura> setting ar.k0 to cached attribute is problematic.
> 
> I don't know about SAL internals, but if SAL uses it in physical mode,
> it needs to make sure that it's accessing it in uncached mode.  This
> seems to work just fine on all existing Intel and HP systems so it
> certainly seems possible.
> 
>   Nomura> I think setting bit63 to 1 (i.e. physical mode uncached) is
>   Nomura> better and safer solution than just putting cached attribute
>   Nomura> physical address in ar.k0, unless anyone or any part of code
>   Nomura> suffers from the bit.
> 
> No, setting bit 63 is not a solution.  k0 must contain the physical
> base address of the legacy I/O space, no more, no less.
> 
> 	--david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


