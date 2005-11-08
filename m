From: Robin Holt <holt@sgi.com>
Date: Tue, 08 Nov 2005 19:36:57 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051108193657.GB22803@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ken,

Can I get you to reproduce this?  I have tried many times and
your test is giving me numbers that are very close between 3
and 4 level page tables.  For 25 runs, I got:

With 3-level page table kernel: Average of 25 is 24612659771.96
With 4-level page table kernel: Average of 25 is 24686556792.96

Which is showing that a vhtp_miss test is adding a 0.30% overhead
which can also be expressed as an average 1.44 clock cycles per
miss.  As of this writing, the loops have run over 250 times and
the min reading to this point is 23946196482.  This is nowhere
close to your min reported.

> With 3-level page table kernel: time is 16405345406
> With 4-level page table kernel: time is 26768668506

Thanks,
Robin Holt
