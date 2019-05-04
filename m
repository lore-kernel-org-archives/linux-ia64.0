From: Christoph Hellwig <hch@lst.de>
Date: Sat, 04 May 2019 06:27:34 +0000
Subject: Re: ERROR: "paddr_to_nid" [drivers/md/raid1.ko] undefined!
Message-Id: <20190504062734.GA30427@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <201905032019.tzlqufi0%lkp@intel.com> <4e48dcb2-6e82-4bbe-3920-e1c5fd5c265a@infradead.org> <3908561D78D1C84285E8C5FCA982C28F7E91BABF@ORSMSX104.amr.corp.intel.com> <0f33a863-4371-06cb-f4bd-1f95165b18f1@physik.fu-berlin.de>
In-Reply-To: <0f33a863-4371-06cb-f4bd-1f95165b18f1@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: "Luck, Tony" <tony.luck@intel.com>, Ming Lei <ming.lei@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, lkp <lkp@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Omar Sandoval <osandov@fb.com>, Christoph Hellwig <hch@lst.de>, "Wu, Fengguang" <fengguang.wu@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Sat, May 04, 2019 at 07:47:08AM +0200, John Paul Adrian Glaubitz wrote:
> Hi Tony!
> 
> On 5/3/19 10:25 PM, Luck, Tony wrote:
> > Big difference is I'm doing a natinve build with a much older compiler (4.6.4)
> 
> Just as a heads-up: There are updated installation images available
> for Debian unstable for ia64 [1]. Those install a fresh system using GRUB
> as a bootloader and come with the latest versions of the toolchain.

Do we also have an x86 to ia64 cross compiler package for Debian?
Those packages really help me with changes to other architectures, and
the lack of them for ia64 makes compile-testing ia64 code rather painful.
