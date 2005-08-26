From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 26 Aug 2005 19:06:17 +0000
Subject: RE: Nasty VMLPT problem...
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F043F45CD@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17163.58446.637451.839535@wombat.chubb.wattle.id.au>
In-Reply-To: <17163.58446.637451.839535@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>+	if ((mapped_space_bits - PAGE_SHIFT > vmlpt_bits - pte_bits) || (mapped_space_bits > impl_va_bits - 1))

I can't quite wrap my brain around what the first half of this test is
checking.  It triggers for a 64K pagesize when impl_va_bits is 51..54,
but what does it mean?

Note also the second half of this test also catches those 4 cases too
(and also the pagesize 64K with impl_va_bitsU), so whatever the first
part is checking is a subset of the 2nd check.  So we could survive with
just "if (mapped_space_bits > impl_va_bits - 1)"

-Tony
