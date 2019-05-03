From: Randy Dunlap <rdunlap@infradead.org>
Date: Fri, 03 May 2019 20:02:09 +0000
Subject: Re: ERROR: "paddr_to_nid" [drivers/md/raid1.ko] undefined!
Message-Id: <4e48dcb2-6e82-4bbe-3920-e1c5fd5c265a@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <201905032019.tzlqufi0%lkp@intel.com>
In-Reply-To: <201905032019.tzlqufi0%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kbuild test robot <lkp@intel.com>, Ming Lei <ming.lei@redhat.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>, Omar Sandoval <osandov@fb.com>, Christoph Hellwig <hch@lst.de>, Tony Luck <tony.luck@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On 5/3/19 5:54 AM, kbuild test robot wrote:
> Hi Ming,
> 
> First bad commit (maybe != root cause):
> 
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   ea9866793d1e925b4d320eaea409263b2a568f38
> commit: 6dc4f100c175dd0511ae8674786e7c9006cdfbfa block: allow bio_for_each_segment_all() to iterate over multi-page bvec
> date:   3 months ago
> config: ia64-bigsur_defconfig (attached as .config)
> compiler: ia64-linux-gcc (GCC) 8.1.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 6dc4f100c175dd0511ae8674786e7c9006cdfbfa
>         # save the attached .config to linux build tree
>         GCC_VERSION=8.1.0 make.cross ARCH=ia64 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> All errors (new ones prefixed by >>):
> 
>    ERROR: "paddr_to_nid" [sound/core/snd-pcm.ko] undefined!
>    ERROR: "paddr_to_nid" [net/sunrpc/sunrpc.ko] undefined!
>    ERROR: "paddr_to_nid" [fs/cifs/cifs.ko] undefined!
>    ERROR: "paddr_to_nid" [drivers/video/fbdev/core/fb.ko] undefined!
>    ERROR: "paddr_to_nid" [drivers/usb/mon/usbmon.ko] undefined!
>    ERROR: "paddr_to_nid" [drivers/usb/core/usbcore.ko] undefined!
>>> ERROR: "paddr_to_nid" [drivers/md/raid1.ko] undefined!
>    ERROR: "paddr_to_nid" [drivers/md/dm-mod.ko] undefined!
>    ERROR: "paddr_to_nid" [drivers/md/dm-crypt.ko] undefined!
>    ERROR: "paddr_to_nid" [drivers/md/dm-bufio.ko] undefined!
>    ERROR: "paddr_to_nid" [drivers/ide/ide-core.ko] undefined!
>    ERROR: "paddr_to_nid" [drivers/ide/ide-cd_mod.ko] undefined!
>    ERROR: "paddr_to_nid" [drivers/gpu/drm/drm.ko] undefined!
>    ERROR: "paddr_to_nid" [drivers/char/agp/agpgart.ko] undefined!
>    ERROR: "paddr_to_nid" [drivers/block/nbd.ko] undefined!
>    ERROR: "paddr_to_nid" [drivers/block/loop.ko] undefined!
>    ERROR: "paddr_to_nid" [drivers/block/brd.ko] undefined!
>    ERROR: "paddr_to_nid" [crypto/ccm.ko] undefined!
> 

---
Exporting paddr_to_nid() in arch/ia64/mm/numa.c fixes all of these build errors.
Is there a problem with doing that?


-- 
~Randy
