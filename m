From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 08 Nov 2005 20:07:02 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <200511082007.jA8K72g18882@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Magenheimer, Dan wrote on Tuesday, November 08, 2005 10:53 AM
> The cost is of course a global (or cpu) variable access for
> every pud/pgd/pmd/pte macro usage, but one would expect the
> global would always be in cache/TLB so the performance impact
> should be near zero.

That is only true when your entire working set fits into the
cache (both kernel and user data).  Here you burn an extra cache
line for global page size variable, it will displace one cache
line for user application.  Enterprise workloads all have working
set much bigger than CPU's last level cache.  In the end, both
kernel and user side hurt with more cache miss rate.

- Ken

