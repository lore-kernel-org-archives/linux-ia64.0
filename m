From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 22 Nov 2004 18:44:06 +0000
Subject: RE: pte bit spin lock
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F026C633A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <419D9911.1080306@yahoo.com.au>
In-Reply-To: <419D9911.1080306@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>But the copy_page_range issue seems to cost about 7% on lmbench fork
>which is fairly significant

Significant to lmbench perhaps ... but there is considerable difference
of opinion about the benefits of micro-benchmarks like this.  On the one
hand they make it easy to see the cost of a particular change, on the
other, too many people give too much weight to these numbers (a 7% change
in fork performance is not going to be measureable for almost all macro
benchmarks).

-Tony
