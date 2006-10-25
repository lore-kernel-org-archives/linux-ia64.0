From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 25 Oct 2006 15:33:30 +0000
Subject: Re: [patch] don't double >> PAGE_SHIFT pointer for /dev/kmem access
Message-Id: <200610250933.31104.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0ods07mim.fsf@jaguar.mkp.net>
In-Reply-To: <yq0ods07mim.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 25 October 2006 03:49, Jes Sorensen wrote:
> This one has been around for a while, but it's a pretty serious bug,
> so if you would push it upstream quickly that would be great. Thanks
> to Bjorn for spotting it.

Bob Montgomery actually noticed it, so I can't take any credit for this :-)
