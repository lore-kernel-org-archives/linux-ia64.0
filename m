From: "Menyhart, Zoltan" <Zoltan.Menyhart@free.fr>
Date: Thu, 03 Feb 2005 01:03:01 +0000
Subject: Abusing region 0
Message-Id: <42017845.9080507@free.fr>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am going to do some experiments: I am going to map some of the
virtual address ranges of a process into the address space of another
one. They are real 64 bit processes, i.e. the region 0 is not used.
Can I abuse this region 0 for mapping the addresses of the neighbor
process into this region ? E.g. if process A has got an address at
0x6000000000001000, then I am going to map it for B at address
0x0000000000001000 ? Wont anything break ?

(I need this trick because the source address can correspond to
anything, like initialized data, BSS, anonymous allocation, etc, i.e.
some SHM just wont work.)

Any advice will be appreciated.

Zoltan Menyhart


