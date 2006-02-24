From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 24 Feb 2006 19:13:03 +0000
Subject: RE: [patch 1/2] remove per-cpu ia64_phys_stacked_size_p8
Message-Id: <200602241913.k1OJD2g15869@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602240233.k1O2Xeg05945@unix-os.sc.intel.com>
In-Reply-To: <200602240233.k1O2Xeg05945@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christian Hildner wrote on Friday, February 24, 2006 2:08 AM
> self-modifing code isn't the straight forward way of programming. So 
> wouldn't it be an idea to let the code crash instead of silently work 
> with a potentially wrong number of registers here, if by any reason the 
> patch mechanism doesn't work.

I should've also *STRESS* that with all current Itanium processor
out there, including upcoming Montecito processor, no patch will
be done with this set of patch.  The default value is what the
hardware has.

There are *NO* processor exist as of today (including tomorrow, and
next month, and next year) that has physical stack register other
than 96 (which is what is encoded in the instruction right now).

- Ken

