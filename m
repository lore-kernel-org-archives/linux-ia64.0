From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 25 Feb 2006 11:55:12 +0000
Subject: Re: [PATCH] altix:  export sn_pcidev_info_get
Message-Id: <20060225115512.GA24439@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060214162337.GA16954@sgi.com> <20060220201713.GA4992@infradead.org> <20060221024710.GB30226@sgi.com> <20060221103633.GA19349@infradead.org> <yq0r75x6jmn.fsf@jaguar.mkp.net>
In-Reply-To: <yq0r75x6jmn.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Mark Maule <maule@sgi.com>, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Feb 21, 2006 at 06:23:12AM -0500, Jes Sorensen wrote:
> Point is that there are cases where tuning requires you to know what
> PCI bridge is below you in order to get the best performance out of a
> card. One can keep a PCI ID blacklist to handle tuning of the PCI
> bridge itself, but it can't handle things that needs to be tuned
> by setting the PCI device's own registers.
> 
> Having a generic API to export this information would be a good thing
> IMHO.

So please submit a patch to add querying/tuning pci bridges.  And please
make it _GPL exports so people don't accidentally use it in their illegal
drivers.
