From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 24 Mar 2004 00:47:30 +0000
Subject: Re: [PATCH] deprecate linkstatd
Message-Id: <200403231647.30619.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0403241114520.11790-200000@woolami.melbourne.sgi.com>
In-Reply-To: <Pine.LNX.4.44.0403241114520.11790-200000@woolami.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David, please apply.  It just kills an obsolete interface to our interconnect 
traffic statistics.

Thanks,
Jesse

On Tuesday 23 March 2004 4:20 pm, Mark Goodwin wrote:
> This patch against 2.6.5-rc2 affects the SGI/SN platform only. It
> deprecates a kernel daemon that has been replaced by a userland tool.
>
> Thanks
>
> -- Mark Goodwin
>    SGI Engineering.
