From: Christian Hildner <christian.hildner@hob.de>
Date: Fri, 16 Jan 2004 06:52:03 +0000
Subject: Re: Mapping addresses 0xe000... and 0xc000...
Message-Id: <40078A13.4060507@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <400714D6.2080609@m6net.fr>
In-Reply-To: <400714D6.2080609@m6net.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan MENYHART schrieb:

> I guess most of my problems with "IA64_LOG_NEXT_BUFFER()", 
> "salinfo_log_wakeup()", the KDB, unwinding the interrupted CPU's 
> stack, etc. are related to the mapping of the addresses 0xe000... and 
> 0xc000...
>
> As far as I can see, when I touch such an address that is not mapped
> by any TR or TC entry (the walker is off for these address ranges), then
> the low level translation fault handler automatically inserts a new TC
> entry that maps the address in the usual way.
>
> Yet an alternate translation fault vector is used if the PSR.ic is off
> (interrupts are disabled), and this handler does not map automatically
> the addresses 0xe000... and 0xc000... 

It is the "data nested TLB vector" that comes into play if PSR.ic is off 
and a TLB miss occurs. This fault is intentionally introduced to enable 
software (OSes) to handle nested faults if they ran into a TLB miss 
while doing low level fault handling. However when receiving that fault 
you do not get any information about it like the faulting address,  the 
instruction address, ... . So software has to meet some conventions to 
be able to handle that kind of nested faults.

> We are obliged to take locks and to disable interrupts, see e.g.
> "IA64_LOG_NEXT_BUFFER()", the KDB.

A solution might be the usage of some (free) TRs together with 
superpages up to 256MB that will be installed before accessing that 
memory locations. But be very carefully when doing that.

>
> Is it a VMM design issue not to allow automatic address mapping
> if the PSR.ic is off ? Should not we revise it :-) ? 

I think it is just a strict RISC design.

> Zoltan Menyhart 

Christian

