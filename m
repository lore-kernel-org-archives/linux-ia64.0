From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 16 Nov 2005 23:08:58 +0000
Subject: RE: [PATCH] RFC : Page table macros
Message-Id: <17275.48138.903510.840987@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051116050037.GF2440@cse.unsw.EDU.AU>
In-Reply-To: <20051116050037.GF2440@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Tony Luck <Luck> writes:

>> The 4 level page table case where things have been left as
>> (4*PAGE_SHIFT - 9) I think shows that abstracting to think about
>> things as entries rather than as pointers is useful.


Tony> However, I can't quite imagine a structure where the entries in
Tony> the _upper_ levels are anything except pointers (unless h/w is
Tony> walking the upper levels and imposes some other structure
Tony> ... but this is not the case for ia64).

Ah.  We're currently working an an implementation of Lietdke's Guarded
Page Tables, where the upper levels contain structures, not pointers.
Mind you, the page table walk code has to change significantly to cope
with this, so  PGD_ENTRY_BITS is not an issue...

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
