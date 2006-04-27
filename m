From: Robin Holt <holt@sgi.com>
Date: Thu, 27 Apr 2006 11:50:35 +0000
Subject: Re: [patch] update sn2 defconfig
Message-Id: <20060427115035.GA24518@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq07j5bs50k.fsf@jaguar.mkp.net>
In-Reply-To: <yq07j5bs50k.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Apr 27, 2006 at 06:10:35AM -0400, Jes Sorensen wrote:
> +CONFIG_NODES_SHIFT=8

Jack/Jes,

Shouldn't we have this at 10 so we get the most exposure possible.

> -# CONFIG_INFINIBAND_IPOIB_DEBUG is not set
> +CONFIG_INFINIBAND_IPOIB_DEBUG=y

Why turn on debugging for everyone?

Robin
