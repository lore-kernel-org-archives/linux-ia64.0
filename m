From: Jack Steiner <steiner@sgi.com>
Date: Fri, 20 Jun 2003 21:04:04 +0000
Subject: Re: 2.5.72 for ia64 released
Message-Id: <marc-linux-ia64-105614315629417@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105605890319553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105605890319553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


    Jesse> Yeah, that's what I meant.  Jack's patch to 2.4 has been
    Jesse> tested on sn2, DIG, zx1, NEC, and Bull machines, as a generic
    Jesse> kernel for the first three at least (don't know what NEC and
    Jesse> Bull did for their testing).

  David> But which ones are NUMA with node-scattered physical memory?  sn2 for
  David> sure.  DIG, zx1 are not, for sure.  I'm not certain about NEC or Bull.
  David> So I'm not convinced that it works for all possible physical memory
  David> layouts.



Takayoshi tested it on an NEC numa system & had no problems with the final
version of the patch.. The memory map for his system was:

	mem00: type=4, attr=0x9, range=[0x0000000000000000-0x0000000000001000) (0MB)
	mem01: type=7, attr=0x9, range=[0x0000000000001000-0x0000000000088000) (0MB)
	mem02: type=4, attr=0x9, range=[0x0000000000088000-0x00000000000a0000) (0MB)
	...
	mem67: type=4, attr=0x9, range=[0x000000041f90d000-0x000000041f9fe000) (0MB)
	mem68: type=7, attr=0x9, range=[0x000000041f9fe000-0x000000041fda4000) (3MB)
	mem69: type=5, attr=0x8000000000000009, range=[0x000000041fda4000-0x000000041fe10000) (0MB)
	mem70: type=7, attr=0x9, range=[0x000000041fe10000-0x000000041ffb2000) (1MB)
	mem71: type=6, attr=0x8000000000000009, range=[0x000000041ffb2000-0x0000000420000000) (0MB)
	mem72: type, attr=0x8000000000000001, range=[0x00000ffffc000000-0x0000100000000000) (64MB)

	SRAT revision 1
	SRAT Processor (id[0x60] eid[0x00]) in proximity domain 6 enabled
	SRAT Processor (id[0x61] eid[0x00]) in proximity domain 6 enabled
	SRAT Processor (id[0x62] eid[0x00]) in proximity domain 6 enabled
	SRAT Processor (id[0x63] eid[0x00]) in proximity domain 6 enabled
	SRAT Processor (id[0x70] eid[0x00]) in proximity domain 7 enabled
	SRAT Processor (id[0x71] eid[0x00]) in proximity domain 7 enabled
	SRAT Processor (id[0x72] eid[0x00]) in proximity domain 7 enabled
	SRAT Processor (id[0x73] eid[0x00]) in proximity domain 7 enabled
	SRAT Memory (0x0000000000000000 length 0x000000000009fc00 type 0x1) in proximity domain 6 enabled
	SRAT Memory (0x0000000000100000 length 0x00000001fff00000 type 0x1) in proximity domain 6 enabled
	SRAT Memory (0x0000000200000000 length 0x0000000200000000 type 0x1) in proximity domain 7 enabled
	SRAT Memory (0x0000000400000000 length 0x0000000020000000 type 0x1) in proximity domain 6 enabled


This testing was on the 2.4.20 version of the patch but I think the 2.5 version is the same - at
least as far as the memmap is concerned.

I dont know if the BULL system was numa but they verified the final version of
the 2.4.20 patch.

No guarantee that it works for everything though...
	



-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com

