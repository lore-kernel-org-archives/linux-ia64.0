From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 25 Sep 2002 19:48:40 +0000
Subject: RE: [Linux-ia64] platform detection at run-time
Message-Id: <marc-linux-ia64-105590701906064@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906051@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906051@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 25 Sep 2002 15:33:12 -0400, Sane_Purushottam@emc.com said:

  Sane> The reason, I have to detect the architecture at run time has
  Sane> to do with the interface with (sg) driver. Since the driver is
  Sane> natively compiled for 64-bit, it expects the data structure
  Sane> handed over to it, to be 64-bit wide.  Thus my 32-bit
  Sane> application cannot issue ioctl calls successfully.

That sounds like a bug in the ia32 subsystem.

There should be no need to do anything special in user level.

	--david

