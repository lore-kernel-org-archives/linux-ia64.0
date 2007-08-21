From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Tue, 21 Aug 2007 20:05:15 +0000
Subject: Re: [PATCH 2/3] dma: override "dma_flags_set_dmaflush" for sn-ia64
Message-Id: <20070821130515.6e745b17.randy.dunlap@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070818002746.GU1813@sgi.com>
	<46C94FD5.6000006@sgi.com>
	<20070821193522.GD5592@sgi.com>
In-Reply-To: <20070821193522.GD5592@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akepner@sgi.com
Cc: Jes Sorensen <jes@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, rdreier@cisco.com, linux-ia64 <linux-ia64@vger.kernel.org>, James.Bottomley@HansenPartnership.com

On Tue, 21 Aug 2007 12:35:22 -0700 akepner@sgi.com wrote:

> 
> > I'm a little concerned about changing the API for the dma_ foo
> > functions, which are defined cross platform. If you want to change
> > that, I think it will require updating the documentation explaining
> > it.....
> 
> What do you think of the following? (And is there anyone else 
> I should be cc-ing for review?)

probably the document's author (cc added)


> Document semantics of dma_flags_set_dmaflush()
> 
> Signed-off-by: Arthur Kepner <akepner@sgi.com>
> --
>  DMA-API.txt |   22 ++++++++++++++++++++++
>  1 files changed, 22 insertions(+)
> 
> diff --git a/Documentation/DMA-API.txt b/Documentation/DMA-API.txt
> index cc7a8c3..e117b72 100644
> --- a/Documentation/DMA-API.txt
> +++ b/Documentation/DMA-API.txt
> @@ -392,6 +392,28 @@ Notes:  You must do this:
>  
>  See also dma_map_single().
>  
> +int
> +dma_flags_set_dmaflush(int dir)
> +
> +Amend dir (one of the enum dma_data_direction values), with a platform-

no comma.

> +specific "dmaflush" attribute. Unless the platform supports "posted DMA" 

add comma after "posted DMA" and drop lots of trailing spaces.

> +this is a no-op. 
> +
> +On platforms that support posted DMA, dma_flags_set_dmaflush() causes 
> +device writes to the associated memory region to flush in-flight DMA. 
> +This can be important, for example, when (DMA) writes to the memory 
> +region indicate that DMA of data is complete. If DMA of data and DMA of 
> +the completion indication race, as they can do when the platform supports 
> +posted DMA, then the completion indication may arrive in host memory 
> +ahead of some data.
> +
> +To prevent this, you might map the memory region used for completion 
> +indications as follows:
> +
> +	int count, flags = dma_flags_set_dmaflush(DMA_BIDIRECTIONAL);
> +	.....
> +	count = dma_map_sg(dev, sglist, nents, flags);
> +
>  
>  Part II - Advanced dma_ usage
>  -----------------------------
> -- 
> Arthur


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
