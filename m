From: n0ano@indstorage.com
Date: Wed, 28 Nov 2001 17:57:09 +0000
Subject: Re: [Linux-ia64] unaligned access?
Message-Id: <marc-linux-ia64-105590698805556@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

D'Laila-

Some basic IA64'isms:

	The instruction pointer points to a bundle that
	includes 3 instructions.  All instruction bundles
	are alligned on a 16-byte boundary.

The instruction pointer as reported by a signal trap frame
encodes both the bundle address and the specific instruction
inside the bundle that caused the fault.  The specific
instruction is encoded in the lowest 4 bits of the bundle
address.  In your situatation, the bundle address was at
0x4000000000003540 and the second instruction (encoded as 1)
in the bundle was the one that caused the fault.

Just anding off the lower 4 bits from `scp->sc_ip' will solve
your problem.


On Wed, Nov 28, 2001 at 09:37:51AM -0800, Pereira, D LailaX E wrote:
> HI 
> While running the following  code, 
> define WRITE_CAUSED_SIGBUS_or_SEGV \
>         (((*(unsigned long*)scp->sc_ip)>>21)&1)
> ....
> if (WRITE_CAUSED_SIGBUS_or_SEGV){
> ........
> }
> else {
> .........
> }
> 
> I get the following error on the "if " statement: 
> stress.udp(31438): unaligned access to
> 0x4000000000003541,ip=0x4000000000015fc1
> Please let me know what is wrong with the macro:
> define WRITE_CAUSED_SIGBUS_or_SEGV \
>         (((*(unsigned long*)scp->sc_ip)>>21)&1)
> 
> 
> thanks
> d'laila
> 
> 
> 
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

