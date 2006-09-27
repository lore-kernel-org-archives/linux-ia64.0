From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 27 Sep 2006 11:26:51 +0000
Subject: Re: __get_free_pages() problem on ia64
Message-Id: <20060927112651.GP5017@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1159283801.4407.16.camel@triumph>
In-Reply-To: <1159283801.4407.16.camel@triumph>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 27, 2006 at 10:38:13AM +0530, Adhiraj wrote:
> Ok, thanks, I will look into it. But the question is why do I get
> addresses beyond 4G (virt_to_phys() of returned addresses) even when I
> use GFP_DMA. Is this a known problem on ia64?

All memory is DMAable as we have an IOMMU.  ZONE_DMA doesn't mean what
you think it means.
