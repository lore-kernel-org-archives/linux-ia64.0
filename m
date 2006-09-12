From: Christoph Lameter <christoph@engr.sgi.com>
Date: Tue, 12 Sep 2006 17:33:50 +0000
Subject: Re: [PATCH 0/8] Optional ZONE_DMA V1
Message-Id: <Pine.LNX.4.64.0609121032310.11278@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 12 Sep 2006, Jack Steiner wrote:

> I'm missing something here. On Altix, currently ALL of the memory is reported
> as being in the DMA zone:
> 
> 	% cat /proc/budd*
> 	Node 0, zone      DMA   3015    116      4      1    ...
> 	Node 1, zone      DMA   4243    355     15      3    ...
> 	Node 2, zone      DMA   4384    113      6      4    ...
> 
> 	% cat /proc/zoneinfo
> 	Node 0, zone      DMA
> 	  pages free     5868
> 	  ...
> 
> The DMA slabs are empty, though.

This is wrong. All memory should be in ZONE_NORMAL since we have no DMA 
restrictions on Altix.

> I assume your patch will switch Altix memory to a different zone, but what happens when
> drivers specify GFP_DMA. 

GFP_DMA is ignored if there is no ZONE_DMA, same as GFP_DMA32 and 
GFP_HIGHMEM.


