From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 16 Aug 2007 05:03:07 +0000
Subject: Enable early console for Ski simulator
Message-Id: <87tzr0kr5g.wl%peterc@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


When using Ski to debug early startup, it's a bit of a pain not to
have printk.

This patch agains 2.6.23-rc? enables the simulated console very early.
It may be worth conditionalising on the command line... but this is
enough for now.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index eaa6a24..a8ada00 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -394,6 +394,13 @@ early_console_setup (char *cmdline)
 	if (!early_serial_console_init(cmdline))
 		earlycons++;
 #endif
+#ifdef CONFIG_HP_SIMSERIAL_CONSOLE
+	{
+		extern struct console hpsim_cons;
+		register_console(&hpsim_cons);
+		earlycons++;
+	}
+#endif
 
 	return (earlycons) ? 0 : -1;
 }

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
