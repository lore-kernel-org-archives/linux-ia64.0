From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 27 Feb 2004 19:33:36 +0000
Subject: Re: [PATCH] sal cleanup
Message-Id: <16447.39824.227452.976378@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 27 Feb 2004 19:24:59 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> Sure.  While we're nitpicking, how about deleting the
  Matthew> 'oem=' and `product=' from the printk?  It currently looks
  Matthew> like:

  Matthew> SAL 3.1: oem=HP, product=, version 2.21

  Matthew> How about instead it reading

  Matthew> SAL 3.1: HP  version 2.21

  Matthew> (if we filled in the product field, it'd read something
  Matthew> like SAL 3.1: HP rx2600 version 2.21 )

Sounds good to me.  The extra blank kills me though... ;-)

	--david
