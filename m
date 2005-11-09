From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 09 Nov 2005 18:22:51 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <200511091822.jA9IMpg00404@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote on Wednesday, November 09, 2005 4:12 AM
> > measured 221 clocks with 3-level page table, versus 298 clocks with
> 
> This looks like approx the amount of stall you would see from a cacheline
> fill.  Is this value the average of a large number of samples a single
> sample.

The value was averaged over 500,000 samples.

- Ken

