From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Feb 2004 19:56:27 +0000
Subject: Re: [PATCH] SAL version is not zero-padded
Message-Id: <16442.23275.295420.953526@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040223191857.GE25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040223191857.GE25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 Feb 2004 19:46:02 +0000, Matthew Wilcox <willy@debian.org> said:

  >>  - printk(KERN_INFO "SAL v%x.%02x: oem=%.32s, product=%.32s\n", +
  >> printk(KERN_INFO "SAL v%x.%x: oem=%.32s, product=%.32s\n",

  >> Eh, it was printing a _byte_.  If you remove the byte-printing, I
  >> suspect you'd also want to switch to a decimal format.

  Matthew> No, it's still BCD encoded.  So it'll go from 0x09 to 0x10
  Matthew> when we move from 3.9 to 3.10.  It just shouldn't be
  Matthew> 0-padded.

Ah, that's OK then.

Thanks,

	--david
