From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 02 Sep 2008 10:46:56 +0000
Subject: Kernel now broken on Ski simulator
Message-Id: <87hc8yddun.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Just a heads-up ... patch 3463a93def55c309f3c0d0a8aaf216be3be42d64
that converted check_sal_cache_flush() to use IPIs broke booting on
Ski, because at present, Ski doesn't implement IPIs (it's a
single-processor simulator, after all).

Until Ski is fixed to implement IPIs, you need to boot with the
force_pal_cache_flush argument to the kernel.

Sorry it took me this long to notice!
--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
