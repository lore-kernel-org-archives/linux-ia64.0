From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 31 Oct 2008 11:49:25 +0000
Subject: Re: Where is asm-ia64 directory in 2.6.27 kernel?
Message-Id: <1225453765.6825.13.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <4104961b0810310445v49e13b85xe85d417bfe9ad979@mail.gmail.com>
In-Reply-To: <4104961b0810310445v49e13b85xe85d417bfe9ad979@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2008-10-31 at 19:45 +0800, jidong xiao wrote:
> Hi,
> 
> I just noticed there is no such a directory now, where are the
> including files re-located?Is it also merged into asm-x86??

arch/ia64/include/asm

Is there a FAQ where I could add it?

Petr

> lfs:/usr/src/linux-2.6.27-rc2/include # ls
> acpi       asm-blackfin  asm-h8300      asm-mips     asm-x86
> Kbuild    media   rdma   video
> asm-alpha  asm-cris      asm-m32r       asm-mn10300  asm-xtensa  keys
>     mtd     rxrpc  xen
> asm-arm    asm-frv       asm-m68k       asm-parisc   crypto      linux
>     net     scsi
> asm-avr32  asm-generic   asm-m68knommu  asm-um       drm
> math-emu  pcmcia  sound
> 
> Regards
> Jason
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

