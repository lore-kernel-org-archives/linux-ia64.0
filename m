From: Mauro Carvalho Chehab <mchehab+huawei@kernel.org>
Date: Sat, 02 May 2020 10:16:41 +0000
Subject: Re: [PATCH 07/14] docs: add IRQ documentation at the core-api book
Message-Id: <20200502110438.1aad7d86@coco.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1588345503.git.mchehab+huawei@kernel.org>
        <2da7485c3718e1442e6b4c2dd66857b776e8899b.1588345503.git.mchehab+huawei@kernel.org>
        <20200502074133.GC342687@linux.ibm.com>
In-Reply-To: <20200502074133.GC342687@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Linux Doc Mailing List <linux-doc@vger.kernel.org>, linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Marc Zyngier <maz@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Harry Wei <harryxiyou@gmail.com>, Alex Shi <alex.shi@linux.alibaba.com>, Tejun Heo <tj@kernel.org>, Alexandre Belloni <alexandre.belloni@bootlin.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Guenter Roeck <linux@roeck-us.net>, Marcos Paulo de Souza <marcos.souza.org@gmail.com>, Zenghui Yu <yuzenghui@huawei.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Rob Herring <robh@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, netdev@vger.kernel.org

Em Sat, 2 May 2020 10:41:33 +0300
Mike Rapoport <rppt@linux.ibm.com> escreveu:

> Hello Mauro,
> 
> On Fri, May 01, 2020 at 05:37:51PM +0200, Mauro Carvalho Chehab wrote:
> > There are 4 IRQ documentation files under Documentation/*.txt.
> > 
> > Move them into a new directory (core-api/irq) and add a new
> > index file for it.  
> 
> Just curious, why IRQ docs got their subdirectory and DMA didn't :)

Heh, you got me... :-)

The rationale I used is that DMA fits nicely being close to other 
memory related documents.  As those currently don't have a subdir,
I opted to not create a DMA-specific dir. I admit that his is a
weak reason. I wouldn't mind placing them on a separate subdir,
if you think it would be worth.

Thanks,
Mauro
