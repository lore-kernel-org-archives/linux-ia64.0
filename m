From: Robin Holt <holt@sgi.com>
Date: Tue, 08 Nov 2005 12:43:25 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051108124324.GA18855@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 07, 2005 at 04:22:32PM -0800, Rohit Seth wrote:
> I think using a 64K page size (may be make that default for IA-64 or
> distribute as another kernel the way SuSE has done) is preferred over
> 4-level page tables....particularly for big memory machines.

For your particular application, that may be the case.  For approx half
of our customers, they _REQUIRE_ their application be certified by the
software vendor.  The vendors usually try to limit their exposure by
certifiying on the smallest set kernel/modules/libraries possible.
We don't control that.

> There is always at least couple of percentage points that an application
> can gain with even smaller memory foot print (like few gig!) by using
> 64K page size for normal pages.

There is also the possibility that the app may be using the pages sparsely
and therefore wasting a larger percentage of time zeroing memory which
is never needed (smaller percent of page fill).

Thanks,
Robin
