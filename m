From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 24 Jun 2002 21:29:25 +0000
Subject: Re: [Linux-ia64] what about SGI IA64 io address map
Message-Id: <marc-linux-ia64-105590701905719@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jun 24, 2002 at 09:13:43PM +0800, Barry Wu wrote:
> Hi, all, I am new to Intel Itanium. I do not know
> if io address is special linux. For example, in mips
> io virtual  address can be converted directly to
> physics address by K1seg. I read Itanium system 
> architecture and find that all virtual address have
> to pass TLB transation. Am I right?

Right.  Though region 7 for linux/ia64 is kind of like k1seg in mips,
and like mips, there's a dedicated translation register setup for it.

> I read include/asm-ia64/sn/sn2/addrs.h and find
> that SGI IA64 address is composed of
> node-id  +  node offset

Yes.

> If all virtual address have to convert by TLB, then
> I think SGI Itanium virtual address have to use
> TR register. But Itanium only has 48 DTR and if
> we use node-id as part of physics address, then 
> each node we have to use a DTR, then SGI IA64 system
> have no too DTR to convert this address. The efficiency
> must be slow for IO address. I do not know if it is
> correct. If someone knows, please give me a reply.

Only one TR is used for mapping I/O space--the one for region 6, which
is uncached direct mapped memory.  Additionaly, I/O space accesses
should only be done through the readX/writeX functions, which can do
things like make sure I/O is coherent and ordered properly.

Was there any particular code snippet that you were confused about?
It might be easier to explain things in that context.

Jesse

