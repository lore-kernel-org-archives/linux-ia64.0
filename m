From: Gerald Pfeifer <gp@suse.de>
Date: Mon, 05 Feb 2007 12:18:16 +0000
Subject: Re: [PATCH] [IA64]: add return to PAL-code warning message
Message-Id: <Pine.LNX.4.64.0702051224380.12094@bvqn.fhfr.qr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070205011737.GC31046@verge.net.au>
In-Reply-To: <20070205011737.GC31046@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 5 Feb 2007, Horms wrote:
> Signed-off-by: Simon Horman <horms@verge.net.au>
> -	printk(KERN_WARNING "%s: no PAL-code memory-descriptor found",
> +	printk(KERN_WARNING "%s: no PAL-code memory-descriptor found\n",
                                                                    ^^

This is usually referred to as newline, not return.  Return, or
carriage return, would be '\r' instead of '\n'.

Gerald
