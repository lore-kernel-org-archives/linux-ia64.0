From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 29 Aug 2005 07:29:30 +0000
Subject: RE: ip_contrack module refuses to load...
Message-Id: <17170.47450.53390.386410@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Tony Luck <Luck> writes:

>> ip_tables: (C) 2000-2002 Netfilter core team ip_conntrack: value
>> -6917529019048071580 out of IMM22 range
>> 
>> in dmesg.
>> 
>> That value doesn't correspond to any symbol I can find in
>> /proc/kallsyms (it's A0000002002EEE64: symbols near there are:

Tony> What an unhelpful error message!  That value will be the address
Tony> in the module that failed to load.  But to do something useful

Actually, it's the target, no the address of the relocation.  Turning
on module debugging helped... turns out it's trying to get at a
per-cpu variable.  The kernel is built UP.

Should the module loader do anything special for per-cpu variables?

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
