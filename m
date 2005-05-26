From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 26 May 2005 20:09:06 +0000
Subject: Re: [patch 0/4] ia64 SPARSEMEM
Message-Id: <17046.11490.222898.96330@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 24 May 2005 12:27:39 -0400, Bob Picco <bob.picco@hp.com> said:

  >> + * SECTION_SIZE_BITS            2^N: how big each section will be

  Bob> I don't perceive VIRTUAL_MEM_MAP as a nicer solution.  Actually
  Bob> SPARSEMEM is a very elegant solution for memory holes and
  Bob> hotplug memory.

Except that it requires configuration?  What happens if
SECTION_SIZE_BITS is chosen wrong or poorly for a given (perhaps new)
platform?

	--david
