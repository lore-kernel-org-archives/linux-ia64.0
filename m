From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 20 Feb 2006 20:17:14 +0000
Subject: Re: [PATCH] altix:  export sn_pcidev_info_get
Message-Id: <20060220201713.GA4992@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060214162337.GA16954@sgi.com>
In-Reply-To: <20060214162337.GA16954@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>, akpm@osdl.org
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Feb 14, 2006 at 10:23:37AM -0600, Mark Maule wrote:
> Export sn_pcidev_info_get.

Tony or Andrew please back this out again.  The only reason SGI wants this is
to support their illegal graphics driver, and no core code uses it.

And Mark, please stop submitting such patches.

