From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 25 Jan 2005 19:57:53 +0000
Subject: RE: optimize __gp location
Message-Id: <200501251957.j0PJvsg17422@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 25 Jan 2005 11:44:34 -0800, "Chen, Kenneth W" said:
  Ken> I don't have any benchmark result off hand.  But digging through recent
  Ken> data, for a well known db benchmark, GOT table access account to about
  Ken> 4% of total memory latency in the kernel.

David Mosberger wrote on Tuesday, January 25, 2005 11:52 AM
>
> 4% actual CPU stalls or 4% of potentially overlapped stalls?
>

4% of total cpu stall cycles.  6% of all memory references (in kernel space).
Though they are very concentrated to a few cache lines.


> I'm not trying to be difficult.  It's just that GOT optimizations so
> far haven't really paid off in any significant way in the benchmarks I
> tried.  You'd think for some benchmarks it does make a significant
> difference (even just based on a cache-pollution argument), I just
> haven't seen it yet...

No biggy, I want to find out myself too whether this has any real impact
or not :-)

- Ken


