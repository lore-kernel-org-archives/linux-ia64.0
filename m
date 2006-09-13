From: Jes Sorensen <jes@sgi.com>
Date: Wed, 13 Sep 2006 07:55:01 +0000
Subject: Re: [PATCH 0/8] Optional ZONE_DMA V1
Message-Id: <yq0hczcfbfu.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Christoph" = Christoph Lameter <christoph@engr.sgi.com> writes:

Christoph> On Tue, 12 Sep 2006, Jack Steiner wrote:
>> I'm missing something here. On Altix, currently ALL of the memory
>> is reported as being in the DMA zone:
>> 
>> % cat /proc/budd* Node 0, zone DMA 3015 116 4 1 ...  Node 1, zone
>> DMA 4243 355 15 3 ...  Node 2, zone DMA 4384 113 6 4 ...
>> 
>> % cat /proc/zoneinfo Node 0, zone DMA pages free 5868 ...
>> 
>> The DMA slabs are empty, though.

Christoph> This is wrong. All memory should be in ZONE_NORMAL since we
Christoph> have no DMA restrictions on Altix.

This is harmless on Altix because we have an IOMMU - however we should
in theory put all memory below 4GB into the DMA32 zone (if there was
any memory there :) to use if we ever ran out of IOMMU slots when
running 32 bit only capable PCI devices. I've never seen this happen
so it's purely theoretical.

Cheers,
Jes
