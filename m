From: Barry Wu <wuqb@nudt.edu.cn>
Date: Mon, 24 Jun 2002 13:13:43 +0000
Subject: [Linux-ia64] =?gb2312?B?d2hhdCBhYm91dCBTR0kgSUE2NCBpbyBhZGRyZXNzIG1hcA==?=
Message-Id: <marc-linux-ia64-105590701905718@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, all, I am new to Intel Itanium. I do not know
if io address is special linux. For example, in mips
io virtual  address can be converted directly to
physics address by K1seg. I read Itanium system 
architecture and find that all virtual address have
to pass TLB transation. Am I right?

I read include/asm-ia64/sn/sn2/addrs.h and find
that SGI IA64 address is composed of
node-id  +  node offset
If all virtual address have to convert by TLB, then
I think SGI Itanium virtual address have to use
TR register. But Itanium only has 48 DTR and if
we use node-id as part of physics address, then 
each node we have to use a DTR, then SGI IA64 system
have no too DTR to convert this address. The efficiency
must be slow for IO address. I do not know if it is
correct. If someone knows, please give me a reply.

Thanks in advance!

Barry 

