From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 09 Aug 2007 04:53:11 +0000
Subject: [PATCH] flush icache before set_pte() on ia64  take9 [0/2] all
Message-Id: <20070809135311.0676a947.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, davem@davemloft.net, "Zoltan.Menyhart@bull.net" <Zoltan.Menyhart@bull.net>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>

synching Icache and Dcache before set_pte() for ia64 take9.

take8 got negative review as "ia64 specific codes are scattered over vm layer
and it will not be able to be maintained." And adivce from David Miller (thanks!)
was modifiying set_pte().

This version modifies set_pte() for inserting "ia64 specific" flush cache code.
It seems that I encoded all conditions for flush_icache necessity in clear way
and the whole code is not invasive.

Any comments are welcome.

Thanks,
-Kame


