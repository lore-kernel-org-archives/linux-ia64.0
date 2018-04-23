From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 23 Apr 2018 13:47:38 +0000
Subject: ia64 platform selection
Message-Id: <20180423134738.GA19816@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony, hi Fenghua,

I'm currently spending a lot of time untangling the various dma mapping
implementations, and one of the many particularly convoluted
architectures there is ia64 due to the machvec mechanism, which
allows both generic plaform support for all supported platforms as well
as for kernel optimized for specific platforms only.

Do you know if there are any users left running kernel optimized for
a specific platform, or if we can make the generic support the only
available option.

Also I'm curious if we have users of the SKI simulator left - it comes
with various pretty bad device drivers, so removing it would probably
make a few subsystem maintainers happy.
