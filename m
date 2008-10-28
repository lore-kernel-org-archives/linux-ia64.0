From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 28 Oct 2008 02:50:16 +0000
Subject: IRQ routing
Message-Id: <874p2xh1qv.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi Folks,
	It looks as if Documentation/IRQ-redir is out of date, since
IA64's /proc/irq was moved to generic code.

How now does one control whether interrupts are fixed route, or use
lowest-priority routing?
--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
