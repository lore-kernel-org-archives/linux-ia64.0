From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 16 Feb 2005 21:02:04 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <16915.46284.544114.558192@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 16 Feb 2005 14:10:56 -0500, Jes Sorensen <jes@wildopensource.com> said:

  Jes> Hmmm for some reason I had the impression PG_arch_1 was only
  Jes> used on PPC/PPC64 for icache current status, but it looks like
  Jes> you're right. Darn ;-(

  Jes> Can't we just drop swiotlb and tell people to buy real
  Jes> hardware? ;-)))

The use of PG_arch_1 has nothing to do with swiotlb.  It lets us
optimize away expensive cache-flushing by taking advantage of the fact
that DMA transactions automatically establish coherency.

	--david
