From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 02 Mar 2004 01:30:18 +0000
Subject: Re: [PATCH] sal cleanup
Message-Id: <16451.58282.35070.522756@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 1 Mar 2004 16:05:32 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> This patch reorganises sal.c and adds a small amount of new
  Matthew> functionality.

The patch breaks UP kernels because SMP_IRQ_REDIRECTION and SMP_IPI_REDIRECTION
aren't defined for UP kernels.

	--david
