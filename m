From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Dec 2004 18:09:17 +0000
Subject: Re: virtual memmap and page_address
Message-Id: <16832.32205.922132.464908@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412150953.32812.jbarnes@engr.sgi.com>
In-Reply-To: <200412150953.32812.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 15 Dec 2004 09:53:32 -0800, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> I've been messing around with some of the drm drivers lately,
  Jesse> and in some cases they'll call pci_map_single on an address
  Jesse> returned from page_address().  When virtual memmaps are
  Jesse> enabled, page_address will return a region 5 pointer.

Huh?  The page _descriptor_ is in region 5, but surely not page_address()?

	--david
