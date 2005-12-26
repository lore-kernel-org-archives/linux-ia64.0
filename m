From: "Tian, Kevin" <kevin.tian@intel.com>
Date: Mon, 26 Dec 2005 05:44:55 +0000
Subject: Why is psr.ic off for ia64_pal_cache_flush?
Message-Id: <571ACEFD467F7749BC50E0A98C17CDD802C06B64@pdsmsx403>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I know that currently there's no such invocation to ia64_pal_cache_flush
within ia64 linux kernel, but like to know why it's the only instance to
call PAL_CALL_IC_OFF under virtual mode? Since there's no DTR setup for
pal area, it can only work if DTC entry exists just before off psr.ic,
or pal procedure for this type doesn't issue any data access. Or else
nested dtlb miss may happen and it seems not to be handled by current
linux code.

Currently this stub is invoked by XEN (an open source VMM with code
derived from linux) to sync I/D cache after management tool loads kernel
image and initrd of another domain (guest OS). Though we may take place
of it by fc.i, I'm still curious to know historical background for this
design.

Thanks in advance,
Kevin
