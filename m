From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 16 Jan 2004 21:39:27 +0000
Subject: Re: [PATCH] Kconfig cleanup, part 1
Message-Id: <16392.23055.812483.701833@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401161136.37066.bjorn.helgaas@hp.com>
In-Reply-To: <200401161136.37066.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


 config IA64_HP_ZX1
-	bool "HP-zx1"
+	bool "HP"

Please don't do this.  You'll get people selecting it for the HP
I2000 and RX4610, which are *not* based on the ZX1 chipset, even
though they're made by HP.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*

