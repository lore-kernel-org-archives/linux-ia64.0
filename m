From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 27 May 2003 20:34:10 +0000
Subject: RE: [Linux-ia64] mmap failure
Message-Id: <marc-linux-ia64-105590723706050@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706049@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706049@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>     it looks like mmap fails when calling mmap as:
> 
>     mmap(0x30000066910000,
>                 16384,
>             PROT_READ | PROT_WRITE,  
>           MAP_FIXED,MAP_PRIVATE,
>        fd,0x30000066910000);
> 
> Other addresses are ok. It fails with EINVAL.
> Is 0x30000... reserved for the kernel ?

0x30000066910000 is too far from a region boundary.

Although Itanium 2 supports a full 64-bit virtual
address space, Linux can't map objects to any place
in the 64-bit range because with a 3-level page
table it can't use all of the address bits.

The areas that can be mapped by Linux are at the
bottom and top of each Itanium "region" (top three
bits of the virtual address are the region number).

-Tony

