From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 17 Mar 2004 17:10:50 +0000
Subject: Re: pgd_free, pmd_free, and pte_free trapping memory.
Message-Id: <16472.34458.139213.286636@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040316112424.GA20203@lnx-holt>
In-Reply-To: <20040316112424.GA20203@lnx-holt>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 17 Mar 2004 10:20:16 -0600, Jack Steiner <steiner@sgi.com> said:

  Jack> 3.1 usec 16K node local memory
  Jack> 6.1 usec 16K remote memory

  Jack> 12.5 usec 64K node local memory
  Jack> 24.5 usec 64K remote memory

Roughly 4.9GByte/sec for local memory.  That sounds about right.

Robin: I certainly agree that per-CPU allocation is the Right Thing
for SMP.  My point is that the quick-list optimization is orthogonal
and my gut feeling is that it's worth doing it.  LMbench on a UP with
and without quicklist should be able to confirm that (and no, I don't
care at all how or where the quicklist optimization is
implemented---just as long as you can take advantage of the fact that
freed directories are already zeroed).

	--david
