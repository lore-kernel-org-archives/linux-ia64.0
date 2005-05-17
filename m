From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 17 May 2005 08:01:41 +0000
Subject: Re: Allocating uncacheable memory from OS
Message-Id: <17033.42213.429006.883695@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <11503.1116315459@kao2.melbourne.sgi.com>
In-Reply-To: <11503.1116315459@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 17 May 2005 17:37:39 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> Is there any ia64 OS routine for allocating uncacheable
  Keith> memory?  I am trying to simulate the SAL/OS interface for MCA
  Keith> handling and the min-state area is expected to be
  Keith> uncacheable.

Jes Sorensen was/has been working on such a thing.

	--david
