From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 12 May 2003 22:50:42 +0000
Subject: Re: [Linux-ia64] [PATCH] 1/4 multi-ioport space support for 2.5
Message-Id: <marc-linux-ia64-105590723705736@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705599@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705599@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 12 May 2003 14:58:41 -0600, Bjorn Helgaas <bjorn_helgaas@hp.com> said:

  Bjorn> I think this is a firmware problem.  On my box, the range for
  Bjorn> Bus 00:01 is more sensible (0x2000-0x2fff)

OK with me, then.  I can boot my box with MMIO enabled, which is
probably a good idea anyhow.  Probably nobody else is running firmware
that old anyhow (I belive the box in question is too old to upgrade to
the latest firmware and I don't use it much anymore anyhow).

	--david

