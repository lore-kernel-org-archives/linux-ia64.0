From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 25 Jan 2005 17:44:43 +0000
Subject: Re: Questionable code in pci_sal_read
Message-Id: <16886.34187.323942.533224@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jek6q1o7p2.fsf@sykes.suse.de>
In-Reply-To: <jek6q1o7p2.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 25 Jan 2005 16:21:45 +0100, Andreas Schwab <schwab@suse.de> said:

  Andreas> These are the first few lines in pci_sal_read:
  Andreas> if ((seg > 255) || (bus > 255) || (devfn > 255) || (reg > 4095))
  Andreas> return -EINVAL;

  Andreas> if ((seg | reg) <= 255) {

  Andreas> When seg <= 255 then ((seg | reg) <= 255) is equivalent to
  Andreas> (reg <= 255).  But pci_sal_write only rejects (seg >
  Andreas> 65535).

  Andreas> The lines come from this changeset:

  Andreas> http://linux.bkbits.net:8080/linux-2.6/cset%40407c8325V8ZAIQkFDRCUNpu5AXqG1g

Ah, yes, that looks wrong.  Looks like the check for (seg > 255) came
from the original pci_sal_read().  The original pci_sal_ext_read() did
check for (seg > 65535).  My bad.

Thanks for catching this.

	--david

