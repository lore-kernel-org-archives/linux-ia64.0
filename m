From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 09 Jun 2004 22:34:12 +0000
Subject: Re: Please requeue atlas3
Message-Id: <16583.36964.328097.688317@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040609165103.GC24864@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040609165103.GC24864@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 9 Jun 2004 17:51:03 +0100, Matthew Wilcox <willy@debian.org> said:

  Matthew> I think the only ISA addition so far is BranchLong which
  Matthew> gets emulated by the kernel.  I hear murmurings of
  Matthew> additional instructions in future processors, but let's
  Matthew> cross that bridge when there's silicon to be had.

There is also the 16-byte-atomic-ops extension.  The Ski simulator has
been supporting that for some time, so in that sense it exists
already:

 $ cat /proc/cpuinfo | grep features
 features   : branchlong, 16-byte atomic ops

;-)

	--david
