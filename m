From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 09 Apr 2001 17:28:18 +0000
Subject: Re: [Linux-ia64] Unresolved symbols when installing modules
Message-Id: <marc-linux-ia64-105590693005382@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005381@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005381@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I don't know what aci_* does, but as far as isa_* is concerned: DIG64
does not support ISA, so you can't link in any drivers that try to
access ISA devices.

	--david

>>>>> On Mon, 9 Apr 2001 13:10:12 -0300, Gustavo Niemeyer <niemeyer@conectiva.com> said:

  Gustavo> Hello there!!  I'm getting some unresolved symbols when
  Gustavo> trying to install modules from kernel 2.4.3 with patch
  Gustavo> 010405 applied. Some of them (isa_*) seem to come from some
  Gustavo> missing definitions in include/asm-ia64/io.h.

  Gustavo> [...]  find kernel -path '*/pcmcia/*' -name '*.o' | xargs
  Gustavo> -i -r ln -sf ../{} pcmcia if [ -r System.map ]; then
  Gustavo> /sbin/depmod -ae -F System.map 2.4.3; fi depmod: ***
  Gustavo> Unresolved symbols in
  Gustavo> /lib/modules/2.4.3/kernel/drivers/char/dtlk.o depmod:
  Gustavo> loops_per_jiffy depmod: *** Unresolved symbols in
  Gustavo> /lib/modules/2.4.3/kernel/drivers/media/radio/
  Gustavo> radio-miropcm20.o depmod: aci_write_cmd depmod:
  Gustavo> aci_indexed_cmd depmod: aci_write_cmd_d depmod: ***
  Gustavo> Unresolved symbols in
  Gustavo> /lib/modules/2.4.3/kernel/drivers/media/video/ pms.o
  Gustavo> depmod: isa_writeb depmod: isa_memcpy_fromio depmod: ***
  Gustavo> Unresolved symbols in
  Gustavo> /lib/modules/2.4.3/kernel/drivers/net/hp100.o depmod:
  Gustavo> isa_memset_io depmod: isa_readl depmod: isa_memcpy_toio
  Gustavo> depmod: isa_memcpy_fromio

  Gustavo> Thanks!!

  Gustavo> -- Gustavo Niemeyer

  Gustavo> [ 2AAC 7928 0FBF 0299 5EB5 60E2 2253 B29A 6664 3A0C ]

  Gustavo> _______________________________________________ Linux-IA64
  Gustavo> mailing list Linux-IA64@linuxia64.org
  Gustavo> http://lists.linuxia64.org/lists/listinfo/linux-ia64

