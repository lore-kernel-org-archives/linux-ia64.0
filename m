From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:51:41 +0000
Subject: serial drivers polishing
Message-Id: <1556369542-13247-1-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Hello folks,


here's another attempt of polishing the serial drivers:

* lots of minor cleanups to make checkpatch happier
  (eg. formatting, includes, inttypes, ...)

* use appropriate logging helpers instead of printk()

* consequent use of mapsize/mapbase fields:
  the basic idea is, all drivers should fill mapbase/mapbase fields at
  init time and later only use those fields, instead of hardcoded values
  (later on, we can add generic helpers for the map/unmap stuff, etc)

* untwisting serial8250_port_size() at all:
  move the iomem size probing to initialization time, move out some
  platform specific magic to corresponding platform code, etc.


Unfortunately, I don't have the actual hardware to really test all
the code, so please let me know if there's something broken in here.


have fun,

--mtx
