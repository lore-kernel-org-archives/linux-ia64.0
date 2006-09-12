From: Arjan van de Ven <arjan@infradead.org>
Date: Tue, 12 Sep 2006 07:30:05 +0000
Subject: Re: [PATCH 0/8] Optional ZONE_DMA V1
Message-Id: <1158046205.2992.1.camel@laptopd505.fenrus.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2006-09-11 at 15:27 -0700, Christoph Lameter wrote:
> Optional ZONE_DMA
> 
> This patch follows up on the earlier work in Andrew's tree to reduce
> the number of zones. The patches allow to go to a minimum of 2 zones.
> This one allows also to make ZONE_DMA optional and therefore the
> number of zones can be reduced to one.
> 
> ZONE_DMA is usually used for ISA DMA devices. Typically modern hardware
> does not have any of these anymore. 

in the x86 / x86-64 world that statement is not correct ;(

while there is no physical bus there is still too much "be exactly as
if" stuff around.



