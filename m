From: Gustavo Niemeyer <niemeyer@conectiva.com>
Date: Mon, 09 Apr 2001 16:10:12 +0000
Subject: [Linux-ia64] Unresolved symbols when installing modules
Message-Id: <marc-linux-ia64-105590693005381@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello there!!

I'm getting some unresolved symbols when trying to install
modules from kernel 2.4.3 with patch 010405 applied. Some of
them (isa_*) seem to come from some missing definitions in
include/asm-ia64/io.h.

[...]
find kernel -path '*/pcmcia/*' -name '*.o' | xargs -i -r ln -sf ../{} pcmcia
if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.4.3; fi
depmod: *** Unresolved symbols in /lib/modules/2.4.3/kernel/drivers/char/dtlk.o
depmod:         loops_per_jiffy
depmod: *** Unresolved symbols in /lib/modules/2.4.3/kernel/drivers/media/radio/
radio-miropcm20.o 
depmod:         aci_write_cmd
depmod:         aci_indexed_cmd
depmod:         aci_write_cmd_d
depmod: *** Unresolved symbols in /lib/modules/2.4.3/kernel/drivers/media/video/
pms.o
depmod:         isa_writeb
depmod:         isa_memcpy_fromio
depmod: *** Unresolved symbols in /lib/modules/2.4.3/kernel/drivers/net/hp100.o
depmod:         isa_memset_io
depmod:         isa_readl
depmod:         isa_memcpy_toio
depmod:         isa_memcpy_fromio

Thanks!!

-- 
Gustavo Niemeyer

[ 2AAC 7928 0FBF 0299 5EB5  60E2 2253 B29A 6664 3A0C ]

