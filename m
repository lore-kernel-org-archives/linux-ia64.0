From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 04 Nov 2005 17:58:51 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04DF5690@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>It turns out that we have measurable performance regression with
>4-level page table running industry database benchmark, the penalty
>is ~0.2% (I thought the number would be smaller than 0.2%, but ...).
>Our resolution with this workload is typically 0.05%.

That makes it tough to make 4-level the default.  If there were a
lot more users that needed 4-level, I might tell Ken he'd have to
just live with it ... but this is only needed for a few HPC jobs
on very, very high end machines.

I'll put the patches into the test tree as they are (with 4-level
as the default) so that we'll get some test exposure in -mm.  But
if they move into the base it will be with 3-level as the default.

-Tony
