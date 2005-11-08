From: "Boehm, Hans" <hans.boehm@hp.com>
Date: Tue, 08 Nov 2005 18:23:57 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <65953E8166311641A685BDF71D8658266C1A25@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Robin Holt
> 
> There is also the possibility that the app may be using the 
> pages sparsely and therefore wasting a larger percentage of 
> time zeroing memory which is never needed (smaller percent of 
> page fill).
> 
And, perhaps less significantly, there is a small set of applications
that try to use page protection to track accesses, e.g. for incremental
GC, faster checkpointing, or software DSM.  I expect those would
generally do considerably worse with 64K pages.

Hans
