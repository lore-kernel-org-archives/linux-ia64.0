From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 25 Jan 2005 19:44:34 +0000
Subject: RE: optimize __gp location
Message-Id: <200501251944.j0PJiZg17310@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 24 Jan 2005 08:51:17 +0100, Christian Hildner said:
  Christian> Did you have benchmarks? Or at least a comparison of the
  Christian> resulting code size. The code size should shrink when
  Christian> more items can be addressed directly. Furthermore the
  Christian> code size should be a good indicator for the performance
  Christian> gain you could achive.

David Mosberger wrote on Monday, January 24, 2005 9:53 AM
> I'm curious about this too.  Ken, do you have a real-world benchmark
> where improved GP-relative addressability actually made a significant
> difference?

I don't have any benchmark result off hand.  But digging through recent
data, for a well known db benchmark, GOT table access account to about
4% of total memory latency in the kernel.

- Ken


