From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 02 Mar 2004 07:46:22 +0000
Subject: Re: [PATCH] sal cleanup
Message-Id: <16452.15310.788589.261603@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Well, this patch is giving me lots of grief.  It appears that old
(prototype) zx1 systems report a huge SAL version:

	SAL 49.29: INTEL   MSL     REF     SAL      version 49.29

Unfortunately, the hardware is too old to upgrade to newer firmware,
yet the hardware is good enough to be useful.  Perhaps we could have a
command-line option to override the SAL version?

	--david
