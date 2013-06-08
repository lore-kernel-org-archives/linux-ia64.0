From: Chen Gang <gang.chen@asianux.com>
Date: Sat, 08 Jun 2013 10:08:05 +0000
Subject: [Suggestion] arch/*/include/asm/bitops.h: about __set_bit() API.
Message-Id: <51B30285.6020503@asianux.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, "dhowells@redhat.com" <dhowells@redhat.com>, tony.luck@intel.com, fenghua.yu@intel.com, yasutake.koichi@jp.panasonic.com
Cc: linux-alpha@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-am33-list@redhat.com, Linux-Arch <linux-arch@vger.kernel.org>

Hello Maintainers:


Several architectures have different __set_bit() API to others, in
standard API, 2nd param of __set_bit() is 'unsigned long *', but:

  in 'min10300', it is 'unsigned char *',
  in 'ia64' and 'alpha', they are 'int' or 'unsigned int'.

If another sub-systems did not notice it, it may lead them to make
mistakes.

It seems related maintainer intended to implement it like that.

So could related maintainers provide the reason for it, so more guys
(e.g. me) can learn about it (at least can avoid related mistakes).


The related information in arch sub-system:

using 'unsigned char *':
  ./mn10300/include/asm/bitops.h:28:#define __set_bit(nr, addr)					\

using 'unsigned int *', implicitly: 
  ./ia64/include/asm/bitops.h:63:__set_bit (int nr, volatile void *addr)

using 'int *', implicitly: (need use 'unsigned', at least)
  ./alpha/include/asm/bitops.h:49:__set_bit(unsigned long nr, volatile void * addr)

using 'unsigned long *' implicitly:
  ./frv/include/asm/bitops.h:164:static inline void __set_bit(unsigned long nr, volatile void *addr)
  
standard API:  
  ./h8300/include/asm/bitops.h:74:#define __set_bit(nr,addr)    set_bit((nr),(addr))
  ./m68k/include/asm/bitops.h:67:#define __set_bit(nr, vaddr)	set_bit(nr, vaddr)
  ./arc/include/asm/bitops.h:293:static inline void __set_bit(unsigned long nr, volatile unsigned long *m)
  ./sh/include/asm/bitops-op32.h:20:static inline void __set_bit(int nr, volatile unsigned long *addr)
  ./hexagon/include/asm/bitops.h:151:static inline void __set_bit(int nr, volatile unsigned long *addr)
  ./s390/include/asm/bitops.h:212:static inline void __set_bit(unsigned long nr, volatile unsigned long *ptr)
  ./x86/include/asm/bitops.h:84:static inline void __set_bit(int nr, volatile unsigned long *addr)
  (others use 'generic')


Thanks.
-- 
Chen Gang

Asianux Corporation
