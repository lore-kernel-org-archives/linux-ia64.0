From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 14 Mar 2002 19:00:15 +0000
Subject: Re: [Linux-ia64] Does IDE DMA work?
Message-Id: <marc-linux-ia64-105590701905283@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905278@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905278@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Mar 2002 15:04:08 +0100, Andreas Schwab <schwab@suse.de> said:

  Andreas> Has anyone got IDE DMA working?  When I try it with 2.4.18
  Andreas> the machine is hanging during partition table reading, with
  Andreas> the disk light constantly on.  It seems like the kernel is
  Andreas> not receiving any answer from the disk.

Yes, we have an ia64 system here with a IDE drive on which IDE DMA
seems to work fine.  However, it's not an Itanium machine and doesn't
use the PIIX (or whatever its called) controller.  I don't think I
have ever succeeded in getting IDE DMA going on a Big Sur machine.  I
never tried to track it down to see whether its a hw or sw problem.

	--david

