From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 18:45:09 +0000
Subject: Re: recent fix for pgd_addr_end
Message-Id: <16963.2741.574122.88743@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
In-Reply-To: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Do we really need to worry about region-crossing in the pgd_addr_end()
macro?  No single vm_area may cros a region boundary.

	--david
