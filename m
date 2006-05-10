From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 10 May 2006 03:42:06 +0000
Subject: [RFC 0/6] IA64 Long Format VHPT support v2
Message-Id: <20060510034206.17792.82504.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-mm@kvack.org, Ian Wienand <ianw@gelato.unsw.edu.au>

Hi,

Following from this message are patches to enable the Long Format VHPT
on IA64, version 2, which I am posting in the hope of community
review.  They are against 2.6.17-rc3

The major changes 

* Create ivt.S dynamically from include files
* Re-jig Kconfig text
* Split into more patches
* Split out most functions into lvhpt.c/lvhpt.h
* Split find_largest_page into separate patch

I think overall, this version should be clearer.  I still have TODO's
related to mca handlers, but I would appreciate comments on this
updated version.

-i
