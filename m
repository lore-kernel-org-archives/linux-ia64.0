From: akepner@sgi.com
Date: Mon, 20 Aug 2007 16:07:09 +0000
Subject: Re: [PATCH 2/3] dma: override "dma_flags_set_dmaflush" for sn-ia64
Message-Id: <20070820160709.GA28963@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070818002746.GU1813@sgi.com> <46C94FD5.6000006@sgi.com>
In-Reply-To: <46C94FD5.6000006@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, rdreier@cisco.com, linux-ia64 <linux-ia64@vger.kernel.org>

On Mon, Aug 20, 2007 at 10:24:53AM +0200, Jes Sorensen wrote:

> I'm a little concerned about changing the API for the dma_ foo
> functions, which are defined cross platform. If you want to change
> that, I think it will require updating the documentation explaining
> it.

Good idea. I'll post a documentation patchette.

> 
> Regarding ARCH_DOES_POSTED_DMA, is that sufficient as a #define or
> does it have to be run-time tested? (does it do anything at this
> stage). I ask since not all ia64 platforms do posted DMA.
> 

I think a #define is exactly what we want here. 

The newly #define-ed function (for now, and maybe forever) does 
nothing except on IA64_SGI_SN2, which does posted DMA. 

-- 
Arthur

