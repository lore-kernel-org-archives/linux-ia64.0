From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 02 Nov 2005 16:11:10 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04D8262A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>We then started discussing this.  For a normal application with the
>same virtual address requirements run on a 4 versus a 3 level page table,
>we would end up with, at most five additional pages of page tables with
>a single cache-line used in each.

What about AIM7?  The extra pages would make a difference on a small
memory machine running thousands of processes.  Is that a concern for
anyone?

-Tony
