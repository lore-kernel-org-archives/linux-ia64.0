From: Bernhard Walle <bwalle@suse.de>
Date: Wed, 07 Mar 2007 09:47:43 +0000
Subject: Re: [Fastboot] [PATCH] saved_max_pfn too small on a specific machine
Message-Id: <20070307094743.GA8098@strauss.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070307082429.GA29770@verge.net.au>
In-Reply-To: <20070307082429.GA29770@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Horms <horms@verge.net.au> [2007-03-07 09:24]:
> As only md is used to calculate saved_max_pfn it seems reasonable
> to move setting saved_max_pfn to imediately after md is validated.
> This shouldn't change the logic at all. And it seems to make what is 
> going on a little clearer.
> 
> As suggested to me by Magnus Damm
> 
> Cc: Magnus Damm <magnus.damm@gmail.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>

(as the original patch was from me)
Acked-by: Bernhard Walle <bwalle@suse.de>

