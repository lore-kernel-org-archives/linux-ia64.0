From: "Peter Chubb" <peterc@gelato.unsw.edu.au>
Date: Sun, 28 Aug 2005 23:48:07 +0000
Subject: RE: Nasty VMLPT problem...
Message-Id: <17170.19767.571786.932459@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <17163.58446.637451.839535@wombat.chubb.wattle.id.au>
In-Reply-To: <17163.58446.637451.839535@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Tony Luck <Luck> writes:

>> + if ((mapped_space_bits - PAGE_SHIFT > vmlpt_bits - pte_bits) ||
>> (mapped_space_bits > impl_va_bits - 1))

Tony> I can't quite wrap my brain around what the first half of this
Tony> test is checking.  It triggers for a 64K pagesize when
Tony> impl_va_bits is 51..54, but what does it mean?


mapped_space_bits-PAGE_SHIFT is the number of ptes needed to map the
address space.  vmlpt_bits-pte_bits is the number of slots available.

The second half of the test is mneant to catch holes.

If mapped_space_bits > impl_va_bits-1 then the mapped space overlaps
the address space hole (although that should probably be
    ((mapped_space_bits > impl_va_bits-1) && (impl_va_bits < 61))
)

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
