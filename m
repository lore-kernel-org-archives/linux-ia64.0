From: Vaibhav Sharma <vaibhav.sh@gmail.com>
Date: Mon, 14 Mar 2005 07:17:07 +0000
Subject: IA64 memory (zx1 mio)
Message-Id: <851caabb0503132305641cfa33@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hello all,
Thanks for all the responses.

Actually, I had downloaded a zx1 mio pdf, and my task involved just to
recognize whether there are any scalability limits at any place....
If my question was wrong...plz spare me...!

I think i had wrongly interpreted the "System Address Map" figure, on
page 12 of the pdf, (site:
http://ftp.parisc-linux.org/docs/chips/zx1-mio.pdf ). It shows the
"zones", memory0, memory1 and memory2, with corresponding addresses.
It says that m0+m1+m2=1+3+252%6 GB, now if 257th GB of address is to
be mapped by zx1, in which memory zone (m0,m1,m2) will it be
mapped..?..if this is not the case, how will zx1 map this giga byte..?
Is it that the physical RAM beyond 256 GB is mapped as memory mapped
I/O..?
it would be great if i could get some more information about zx1 chip.
plz do respond..
TIA
--
vaibhav
