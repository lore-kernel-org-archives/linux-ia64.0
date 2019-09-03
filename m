From: Paul Burton <paul.burton@mips.com>
Date: Tue, 03 Sep 2019 08:57:00 +0000
Subject: Re: [PATCH 04/26] mips: remove ioremap_cachable
Message-Id: <MWHPR2201MB1277E4E8214F6E50E5EC9BFCC1B90@MWHPR2201MB1277.namprd22.prod.outlook.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190817073253.27819-5-hch@lst.de>
In-Reply-To: <20190817073253.27819-5-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, "x86@kernel.org" <x86@kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "nios2-dev@lists.rocketboards.org" <nios2-dev@lists.rocketboards.org>

Hello,

Christoph Hellwig wrote:
> Just define ioremap_cache directly.

Applied to mips-next.

> commit 60af0d94cc37
> https://git.kernel.org/mips/c/60af0d94cc37
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Paul Burton <paul.burton@mips.com>

Thanks,
    Paul

[ This message was auto-generated; if you believe anything is incorrect
  then please email paul.burton@mips.com to report it. ]
