From: Michael Madore <mmadore@turbolinux.com>
Date: Tue, 05 Feb 2002 20:43:17 +0000
Subject: [Linux-ia64] Proper fix for sym53c8xx_2 driver and dma64_addr_t
Message-Id: <marc-linux-ia64-105590698805991@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Back in early december, it was brought up that eh sym53c8xx_2 driver
makes use of dma64_addr_t, which is not defined on IA64.  I got the
impression that it was the driver that needed to be modified to correct
the problem, but I don't recall seeing a specific solution.  I was going
to simply replace dma64_addr_t with u64 in sym_glue.c for now.  Is there
a better way?

Mike

