From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 25 Jan 2005 19:51:46 +0000
Subject: RE: optimize __gp location
Message-Id: <16886.41810.141106.857004@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 25 Jan 2005 11:44:34 -0800, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> I don't have any benchmark result off hand.  But digging through recent
  Ken> data, for a well known db benchmark, GOT table access account to about
  Ken> 4% of total memory latency in the kernel.

4% actual CPU stalls or 4% of potentially overlapped stalls?

I'm not trying to be difficult.  It's just that GOT optimizations so
far haven't really paid off in any significant way in the benchmarks I
tried.  You'd think for some benchmarks it does make a significant
difference (even just based on a cache-pollution argument), I just
haven't seen it yet...

	--david
