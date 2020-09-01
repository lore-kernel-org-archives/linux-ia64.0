From: Helge Deller <deller@gmx.de>
Date: Tue, 01 Sep 2020 16:41:12 +0000
Subject: Re: [PATCH 07/28] 53c700: improve non-coherent DMA handling
Message-Id: <77c9b2b6-bedc-d090-8b23-6ac664df1d1f@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200819065555.1802761-1-hch@lst.de>
 <20200819065555.1802761-8-hch@lst.de>
 <1598971960.4238.5.camel@HansenPartnership.com>
 <20200901150554.GN14765@casper.infradead.org>
 <1598973776.4238.11.camel@HansenPartnership.com>
 <3369218e-eea4-14e9-15f1-870269e4649d@gmx.de>
In-Reply-To: <3369218e-eea4-14e9-15f1-870269e4649d@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>, Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, Mauro Carvalho Chehab <mchehab@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Joonyoung Shim <jy0922.shim@samsung.com>, Seung-Woo Kim <sw0312.kim@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Ben Skeggs <bskeggs@redhat.com>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Matt Porter <mporter@kernel.crashing.org>, iommu@lists.linux-foundation.org, Tom Lendacky <thomas.lendacky@amd.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, nouveau@lists.freedesktop.org, netdev@vger.kernel.org, linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org

On 01.09.20 18:21, Helge Deller wrote:
> On 01.09.20 17:22, James Bottomley wrote:
>> On Tue, 2020-09-01 at 16:05 +0100, Matthew Wilcox wrote:
>>> On Tue, Sep 01, 2020 at 07:52:40AM -0700, James Bottomley wrote:
>>>> I think this looks mostly OK, except for one misnamed parameter
>>>> below. Unfortunately, the last non-coherent parisc was the 700
>>>> series and I no longer own a box, so I can't test that part of it
>>>> (I can fire up the C360 to test it on a coherent arch).
>>>
>>> I have a 715/50 that probably hasn't been powered on in 15 years if
>>> you need something that old to test on (I believe the 725/100 uses
>>> the 7100LC and so is coherent).  I'll need to set up a cross-compiler
>>> ...
>>
>> I'm not going to say no to actual testing, but it's going to be a world
>> of pain getting something so old going.  I do have a box of older
>> systems I keep for architectural testing that I need to rummage around
>> in ... I just have a vague memory that my 715 actually caught fire a
>> decade ago and had to be disposed of.
>
> I still have a zoo of machines running for such testing, including a
> 715/64 and two 730.
> I'm going to test this git tree on the 715/64:
> git://git.infradead.org/users/hch/misc.git dma_alloc_pages

This tree boots nicely (up to a command prompt with i82596 nic working):

53c700: Version 2.8 By James.Bottomley@HansenPartnership.com
scsi0: 53c710 rev 2
scsi host0: LASI SCSI 53c700
scsi 0:0:6:0: Direct-Access     QUANTUM  FIREBALL_TM3200S 300X PQ: 0 ANSI: 2
scsi target0:0:6: Beginning Domain Validation
scsi 0:0:6:0: tag#56 Enabling Tag Command Queuing
scsi target0:0:6: asynchronous
scsi target0:0:6: FAST-10 SCSI 10.0 MB/s ST (100 ns, offset 8)
scsi target0:0:6: Domain Validation skipping write tests
scsi target0:0:6: Ending Domain Validation
scsi 0:0:6:1: tag#63 Disabling Tag Command Queuing
st: Version 20160209, fixed bufsize 32768, s/g segs 256
sd 0:0:6:0: Power-on or device reset occurred
sd 0:0:6:0: Attached scsi generic sg0 type 0
LASI 82596 driver - Revision: 1.30
Found i82596 at 0xf0107000, IRQ 17
eth0: 82596 at 0xf0107000, 08:00:09:c2:9e:60 IRQ 17.
sd 0:0:6:0: [sda] 6281856 512-byte logical blocks: (3.22 GB/3.00 GiB)
sd 0:0:6:0: [sda] Write Protect is off

Christoph, you may add a
Tested-by: Helge Deller <deller@gmx.de> # parisc
to the series.

Helge
