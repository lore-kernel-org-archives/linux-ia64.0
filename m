From: Rich Altmaier <richa@engr.sgi.com>
Date: Mon, 24 Feb 2003 18:12:44 +0000
Subject: Re: [Linux-ia64] How linux support ccNUMA machine?
Message-Id: <marc-linux-ia64-105590709805916@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805854@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805854@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Barry, 
Some general comments on our experience with using Intel's SAL and PAL
on our Altix system (up to 64p SSI):
-The PAL spec specifies whether functions must be called by each CPU, or
 has a system wide effect and may be called by any one CPU.  In general
 most all PAL functions operate only on, and retrieve info for, just the
 calling CPU.
-The SAL spec also specifies this.  The SAL spec expects that memory is
 globally accessible.  Most SAL functions operate on a shared global
 data structure, and specify that only one CPU need make a call to set
 state for all CPUs.  
-We have found very little problem with PAL & SAL in our global shared
 memory system.

The right way to figure out your situation is to proceed:
a) get a detailed spec from your hardware designer as to exactly
   what operations are "propagated" between FSBs, and which software
   has to be responsible for.
b) understand very clearly how physical address space is being shared,
   and the global view each CPU will have.   Hardware designs can do
   bizarre things in providing partial sharing.  You should argue these
   things are foolish if they are not readily supportable by software.
c) look over the PAL and SAL specs as noted above.

I hope this is helpful,
Thanks, Rich

Rich Altmaier, SGI


Barry Wu wrote:
> 
> Hi, Gilad,
> 
> >I parse your question as: is the Linux kernel on the Altix 3000 aware of
> >ccNUMA or is this something that gets dealt in firmware?
> My question as: linux kernel can support ccNUMA, but it is based on
> firmware.
> Then is firmware responsible to finish ccNUMA initialization?
> If so, because Itanium2 firmware address is at 4GB-16MB, and 4cpus consist
> of mainboard, if to support 64cpus, there will be 16 mainboards. Because
> linux is only one copy: one text and one data segment. When linux startup,
> if it want to call firmware functions (such as PAL, SAL or even EFI), which
> cpu's mainboard firmware to access? Or access its own mainboard, or access
> id 0 cpu mainboard? because the memory is global shared.
> 
> If you know, please give me some infomation. Thanks again for your reply.
> 
> Best Regards,
> 
> Barry
>

