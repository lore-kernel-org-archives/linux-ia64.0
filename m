From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 01 Mar 2005 19:23:21 +0000
Subject: Re: [Patch 1/3] Reclaim pmd and pte entries to quicklists.
Message-Id: <16932.49449.300899.778608@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050226142541.GE10965@lnx-holt.americas.sgi.com>
In-Reply-To: <20050226142541.GE10965@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 26 Feb 2005 08:25:41 -0600, Robin Holt <holt@sgi.com> said:

  Robin> Tony, This patch introduces using the quicklists for pgd,
  Robin> pmd, and pte levels by combining the alloc and free functions
  Robin> into a common set of routines.  This greatly simplifies the
  Robin> reading of this header file.

Agreed, but now you implicitly assume that the directories at all
levels are the same size.  I think it would be better to pass the
desired size to the alloc routine such that you can at least fail
noisily if somebody ever tried to use different-size directories.

  Robin> Before:
  Robin> Process fork+exit: 255.0909 microseconds

  Robin> After:
  Robin> Process fork+exit: 184.2333 microseconds

Nice.

  Robin> +	ret = local_cpu_data->pgtable_quicklist;

Is there any reason pgtable_quicklist isn't a normal per-CPU variable?
We didn't use to have that facility, that's why we used to keep it in
local_cpu_data, but noadays, there should be no need for that ugly
hack.

Since this is performance-critical, it's probably worthwhile to use
__ia64_per_cpu_var() to access the quicklist.  That way, the address
of pgtable_quicklist can be obtained with a single "addl" instruction.

	--david


