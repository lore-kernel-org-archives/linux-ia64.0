From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 19 Sep 2002 22:02:02 +0000
Subject: [Linux-ia64] Broadcom 5700 ethernet drivers
Message-Id: <marc-linux-ia64-105590701906042@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The 2.4 ia64 tree currently has two drivers for Broadcom 5700
devices: the "tg3" driver by Dave Miller and Jeff Garzik, and the
"bcm" driver from Broadcom.

The tg3 driver is in the official kernels from Marcelo and Linus,
is being actively maintained, and seems to be the current driver
of choice.

The bcm driver is not in the upstream kernels, and doesn't seem
to be headed there.

If you would like to keep the bcm driver in the 2.4 ia64 patches,
please speak up and give me an idea of how long you'll need it,
because I don't want to maintain the patch indefinitely.

Bjorn


