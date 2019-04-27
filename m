From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:51:45 +0000
Subject: [PATCH 04/41] drivers: tty: serial: dz: fix use fix bare 'unsigned'
Message-Id: <1556369542-13247-5-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Fix checkpatch warnings:

    WARNING: Prefer 'unsigned int' to bare use of 'unsigned'
    #103: FILE: dz.c:103:
    +static u16 dz_in(struct dz_port *dport, unsigned offset)

    WARNING: Prefer 'unsigned int' to bare use of 'unsigned'
    #110: FILE: dz.c:110:
    +static void dz_out(struct dz_port *dport, unsigned offset, u16 value)

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/dz.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/tty/serial/dz.c b/drivers/tty/serial/dz.c
index b3e9313..559d076 100644
--- a/drivers/tty/serial/dz.c
+++ b/drivers/tty/serial/dz.c
@@ -100,14 +100,14 @@ static inline struct dz_port *to_dport(struct uart_port *uport)
  * ------------------------------------------------------------
  */
 
-static u16 dz_in(struct dz_port *dport, unsigned offset)
+static u16 dz_in(struct dz_port *dport, unsigned int offset)
 {
 	void __iomem *addr = dport->port.membase + offset;
 
 	return readw(addr);
 }
 
-static void dz_out(struct dz_port *dport, unsigned offset, u16 value)
+static void dz_out(struct dz_port *dport, unsigned int offset, u16 value)
 {
 	void __iomem *addr = dport->port.membase + offset;
 
-- 
1.9.1
