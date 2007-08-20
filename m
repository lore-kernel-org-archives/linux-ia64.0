From: Jes Sorensen <jes@sgi.com>
Date: Mon, 20 Aug 2007 08:24:53 +0000
Subject: Re: [PATCH 2/3] dma: override "dma_flags_set_dmaflush" for sn-ia64
Message-Id: <46C94FD5.6000006@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070818002746.GU1813@sgi.com>
In-Reply-To: <20070818002746.GU1813@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akepner@sgi.com
Cc: linux-kernel <linux-kernel@vger.kernel.org>, rdreier@cisco.com, linux-ia64 <linux-ia64@vger.kernel.org>

akepner@sgi.com wrote:
> Define ARCH_DOES_POSTED_DMA, and override the dma_flags_set_dmaflush 
> function. Also define dma_flags_get_direction, dma_flags_get_dmaflush 
> to retrieve the direction and "dmaflush attribute" from flags 
> passed to the sn_dma_map_* functions.
> 

Hi Arthur,

I'm a little concerned about changing the API for the dma_ foo
functions, which are defined cross platform. If you want to change
that, I think it will require updating the documentation explaining
it.

Regarding ARCH_DOES_POSTED_DMA, is that sufficient as a #define or
does it have to be run-time tested? (does it do anything at this
stage). I ask since not all ia64 platforms do posted DMA.

Cheers,
Jes
