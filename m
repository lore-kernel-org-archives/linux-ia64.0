From: "jidong xiao" <jidong.xiao@gmail.com>
Date: Fri, 31 Oct 2008 11:45:02 +0000
Subject: Where is asm-ia64 directory in 2.6.27 kernel?
Message-Id: <4104961b0810310445v49e13b85xe85d417bfe9ad979@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

I just noticed there is no such a directory now, where are the
including files re-located?Is it also merged into asm-x86??

lfs:/usr/src/linux-2.6.27-rc2/include # ls
acpi       asm-blackfin  asm-h8300      asm-mips     asm-x86
Kbuild    media   rdma   video
asm-alpha  asm-cris      asm-m32r       asm-mn10300  asm-xtensa  keys
    mtd     rxrpc  xen
asm-arm    asm-frv       asm-m68k       asm-parisc   crypto      linux
    net     scsi
asm-avr32  asm-generic   asm-m68knommu  asm-um       drm
math-emu  pcmcia  sound

Regards
Jason
