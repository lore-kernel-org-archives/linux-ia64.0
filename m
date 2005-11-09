From: Robin Holt <holt@sgi.com>
Date: Wed, 09 Nov 2005 12:11:47 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051109121147.GA17866@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Have we all agreed by now that the performance hit is relatively minor
(unmeasurable for most cases due to it being less than the noise of the
samples) from 4-level page tables?  Do I need to do any more performance
measurements?

> measured 221 clocks with 3-level page table, versus 298 clocks with

This looks like approx the amount of stall you would see from a cacheline
fill.  Is this value the average of a large number of samples a single
sample.

Thanks,
Robin
