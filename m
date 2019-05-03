From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 03 May 2019 20:10:03 +0000
Subject: RE: ERROR: "paddr_to_nid" [drivers/md/raid1.ko] undefined!
Message-Id: <3908561D78D1C84285E8C5FCA982C28F7E91BA9B@ORSMSX104.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201905032019.tzlqufi0%lkp@intel.com>
 <4e48dcb2-6e82-4bbe-3920-e1c5fd5c265a@infradead.org>
In-Reply-To: <4e48dcb2-6e82-4bbe-3920-e1c5fd5c265a@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <rdunlap@infradead.org>, lkp <lkp@intel.com>, Ming Lei <ming.lei@redhat.com>
Cc: "kbuild-all@01.org" <kbuild-all@01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Omar Sandoval <osandov@fb.com>, Christoph Hellwig <hch@lst.de>, "Wu, Fengguang" <fengguang.wu@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

From: Randy Dunlap [mailto:rdunlap@infradead.org] 
>>    ERROR: "paddr_to_nid" [drivers/block/brd.ko] undefined!
>>    ERROR: "paddr_to_nid" [crypto/ccm.ko] undefined!
>> 
>
> ---
> Exporting paddr_to_nid() in arch/ia64/mm/numa.c fixes all of these build errors.
> Is there a problem with doing that?

I don't see a problem with exporting it.

-Tony
