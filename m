From: Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>
Date: Sat, 23 Mar 2002 00:20:37 +0000
Subject: Re: [Linux-ia64] Sym53c8xxx woes
Message-Id: <marc-linux-ia64-105590701905333@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905332@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905332@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Aaron,

I guess the compile error would be caused due to no definition
of dma64_addr_t. right?
I that case, you can make a kernel with setting "DMA addressing mode"
to be 0. DMA 64bit mode for Sym53c8xx won't work on AzusA, anyway.

Regards,
Kimi


On Fri, 22 Mar 2002 15:40:48 -0800 (PST)
Aaron Burt <aaron@osdl.org> wrote:

> OK, so I've upgraded our NEC AzusA 16-way to 2.4.18, and ran into a li'l
> problem.  When I've 20GB of RAM or more enabled, the Sym53c8xxx v1 driver
> crases on boot.  The v2 driver won't even compile.
> 
> Luckily, the SCSI drives are all on a qla1280 controller, so I can simply
> leave the Symbios support out, but still this is a problem.
> 
> Without the Symbios driver, I can run it with all 16 procs and 32GB ram.
> 
> ObPlug: Our 16-way is available to all and sundry, and I'm currently
> bringing up a couple of 4-way Lions as well.  A couple 2-ways are in the
> pipeline.
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>


