From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 14 Mar 2002 19:01:40 +0000
Subject: Re: [Linux-ia64] Does IDE DMA work?
Message-Id: <marc-linux-ia64-105590701905284@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905278@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905278@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Mar 2002 15:19:46 +0100, Roman Hodek <roman@caldera.de> said:

  Roman> I noticed similar problems some time ago (2.4.13 AFAICR). Our
  Roman> test plan said "test with an IDE disk > 64GB", so we plugged
  Roman> one in and the kernel said nothing more than "DMA
  Roman> timeout". But it's not necessarily the kernel, it also could
  Roman> be that the IDE interface on the legacy I/O board isn't able
  Roman> to do all IDE features properly. Has anybody used it for
  Roman> devices other than CD-ROM and LS120?

Yes, we have one Big Sur that has only IDE drives (4GB, if you can
believe it... ;-).

	--david

