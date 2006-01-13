From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 13 Jan 2006 19:58:42 +0000
Subject: build broken for ia64 simserial.c
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F056BA512@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Alan,

TTY layer buffering revamp broke ia64.

  CC      arch/ia64/hp/sim/simserial.o
arch/ia64/hp/sim/simserial.c: In function `receive_chars':
arch/ia64/hp/sim/simserial.c:170: error: structure has no member named `flip'
arch/ia64/hp/sim/simserial.c:172: error: structure has no member named `flip'
arch/ia64/hp/sim/simserial.c:174: error: structure has no member named `flip'
arch/ia64/hp/sim/simserial.c:176: error: structure has no member named `flip'
arch/ia64/hp/sim/simserial.c:177: error: structure has no member named `flip'
arch/ia64/hp/sim/simserial.c:178: error: structure has no member named `flip'
make[1]: *** [arch/ia64/hp/sim/simserial.o] Error 1

Any quick hints on the fix?

-Tony
