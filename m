From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Tue, 12 Sep 2006 02:40:29 +0000
Subject: Re: [PATCH 3/6] Optional ZONE_DMA in the VM
Message-Id: <45061E1D.4060407@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222744.4849.26386.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222744.4849.26386.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:

>On Tue, 12 Sep 2006, Nick Piggin wrote:
>
>
>>I can't see from your patches, but what happens if someone asks
>>for a GFP_DMA page or dma slab allocation when there is no ZONE_DMA?
>>
>
>The page/slab allocator will simply ignore the flag and return 
>ZONE_NORMAL memory. See gfp_zone().
>

That's wrong, I think? It should return NULL surely? (and possibly do
a printk telling the user they should enable ZONE_DMA config, although
some users have valid fallback strategies).

--

Send instant messages to your online friends http://au.messenger.yahoo.com 
