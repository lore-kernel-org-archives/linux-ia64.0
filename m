From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 03 Feb 2006 17:07:47 +0000
Subject: RE: [PATCH 1/12] generic *_bit()
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F059C0E92@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060126032918.GB9984@miraclelinux.com>
In-Reply-To: <20060126032918.GB9984@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk+lkml@arm.linux.org.uk>, Geert Uytterhoeven <geert@linux-m68k.org>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Christoph Hellwig <hch@infradead.org>, Akinobu Mita <mita@miraclelinux.com>, Grant Grundler <iod00d@hp.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

> > Intel doesn't care about big endian (cfr. your lkml back issues of January
> > 2006).
> 
> Incorrect.  Intel does actually produce big endian CPUs - most of the
> Intel IXP (ARM based) stuff is big endian.  It just depends which part
> of Intel you're referring to.

Set PSR.be (and DCR.be) to 1 and ia64 becomes a big-endian cpu (which,
IIRC, how HP-UX uses it).

-Tony
