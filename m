From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 11 Jan 2005 22:12:08 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <16868.20280.382146.632034@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 11 Jan 2005 12:00:02 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> SGI sn2 systems based on SHub 1.x chipsets don't support the
  Jesse> write combine attribute on PIO space, only regular memory
  Jesse> space.  This is a problem because drivers often expect to map
  Jesse> PIO space with certain memory attributes (e.g.  the PCI mmap
  Jesse> code, drm, fbmem, acorn video).  None of the calls to
  Jesse> pgprot_writecombine are in performance critical paths, so
  Jesse> would making pgprot_writecombine into a machine vector would
  Jesse> be ok?  Comments?

This seems wrong to me.  pgprot_writecombine() should do what it says,
no more and no less.

The EFI memory-map has already all the info needed to determine
whether write-combine mapping is supported, so perhaps the code should
be changed to take that into consideration instead?

	--david
