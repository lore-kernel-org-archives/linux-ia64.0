From: Bob Picco <bob.picco@hp.com>
Date: Thu, 26 May 2005 21:51:09 +0000
Subject: Re: [patch 0/4] ia64 SPARSEMEM
Message-Id: <20050526215109.GK23448@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

luck wrote:	[Thu May 26 2005, 05:34:24PM EDT]
> 
> >I went back and reviewed Jack's email.  I must be blind but don't see why
> >he would need more than 44 bits of physical memory bits.  I agree that
> >should you need 50 bits for physical address bits then you should use
> >32 bits for SECTION_SIZE_BITS.
> 
> Jack's e-mail only really covered the banks of memory within a node.  A
> physical address on Altix looks like this:
> 
> 	+-------------------------------------------------------+
>       | 0   | NASID | AS | BN | 00 |     bank-offset          |
>       +-------------------------------------------------------+
> 
> Where "NASID" is a physical node number ... 11 bits I think
>       "AS" defines the type of memory ... 2-bits with value 0x3 for normal memory
>       "BN" is the bank number within a node.
> 
> A system with N nodes doesn't necessarily have NASIDs assigned 0, 1, ... N-1
> 
> It is theoretically possible to build a 2-node system with NASIDs of 0 and 2047
> [though SGI have told me that this isn't usually done].  But just for grins the
> memory map for this with 4G on each of the two nodes looks like:
> 
> Node 0:
> 	0x0000003000000000-0x000000303FFFFFFF (bank 0)
> 	0x0000003400000000-0x000000343FFFFFFF (bank 1)
> 	0x0000003800000000-0x000000383FFFFFFF (bank 2)
> 	0x0000003C00000000-0x0000003C3FFFFFFF (bank 3)
> Node 1:
> 	0x0001FFF000000000-0x0001FFF03FFFFFFF (bank 0)
> 	0x0001FFF400000000-0x0001FFF43FFFFFFF (bank 1)
> 	0x0001FFF800000000-0x0001FFF83FFFFFFF (bank 2)
> 	0x0001FFFC00000000-0x0001FFFC3FFFFFFF (bank 3)
> 
> (and I may have slipped a binary bit here ... perhaps SGI only
> needs 49 bits, not 50).
> 
okay. thanks for explanation.
> >> a smaller number ... his banks of memory all start on 4G boundaries,
> >> but could be as small as 1G ... can you have a chunk with an empty
> >> tail?).
> 
> You didn't explicitly answer this question ... all the banks in the Altix
> start on 4G boundaries ... but the DIMM size is 1G ... so will this compell
> them to use a CHUNK size of 30 (to handle the 1G increment), or can they
> use 32?
Sorry.  I would use 30.  Unless banks need to be totally populated.  For that
case 32 to reduce sectionmap size for SPARSEMEM.
> 
> >Well worse case it would consume 2^(1(50-32)+3) (2 Mb).  I would hope that 
> >it's not configured for 28 SECTION_SIZE_BITS and 50 physical. This would
> >be excessive 2^((50-28)+3 = 32Mb and not advised.
> 
> I think they need 49 and either 32 or 30 ... depending on whether a chunk
> has to be fully populated.
It doesn't have to be fully populated but we'd like to minimize reserved
pages.
> 
> -Tony
bob
