From: Aaron Burt <aaron@osdl.org>
Date: Fri, 22 Mar 2002 23:40:48 +0000
Subject: [Linux-ia64] Sym53c8xxx woes
Message-Id: <marc-linux-ia64-105590701905332@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK, so I've upgraded our NEC AzusA 16-way to 2.4.18, and ran into a li'l
problem.  When I've 20GB of RAM or more enabled, the Sym53c8xxx v1 driver
crases on boot.  The v2 driver won't even compile.

Luckily, the SCSI drives are all on a qla1280 controller, so I can simply
leave the Symbios support out, but still this is a problem.

Without the Symbios driver, I can run it with all 16 procs and 32GB ram.

ObPlug: Our 16-way is available to all and sundry, and I'm currently
bringing up a couple of 4-way Lions as well.  A couple 2-ways are in the
pipeline.


