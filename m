From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 27 May 2004 18:39:26 +0000
Subject: Re: a elilo.conf question
Message-Id: <16566.13790.715211.53735@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.GSO.4.58.0405271410140.660@tokyo.cc.gatech.edu>
In-Reply-To: <Pine.GSO.4.58.0405271410140.660@tokyo.cc.gatech.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 27 May 2004 14:21:52 -0400 (EDT), Younggyun Koh <young@cc.gatech.edu> said:

  Younggyun> but when kernel being loaded, i got this error message...

  Younggyun> VFS:Cannot open root device "sda3" or unknown-block(0,0)
  Younggyun> Please append a currect "root=" boot option Kernel panic:
  Younggyun> VFS: Unable to mount root fs on unknown-block(0,0)

  Younggyun> (/dev/sda3 is mounted to / in the kernel 2.4)

  Younggyun> the itanium 2 machine i'm using is hp zx6000

That's usually an indication that the disk driver is missing.
Depending on your host controller, you may need to enable

CONFIG_FUSION=y

and/or

CONFIG_SCSI_SYM53C8XX_2=y
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS
CONFIG_SCSI_SYM53C8XX_MAX_TAGSd

	--david
