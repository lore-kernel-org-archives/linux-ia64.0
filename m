From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 11 Jan 2005 20:00:02 +0000
Subject: pgprot_writecombine & shub 1.x
Message-Id: <200501111200.02504.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

SGI sn2 systems based on SHub 1.x chipsets don't support the write combine 
attribute on PIO space, only regular memory space.  This is a problem because 
drivers often expect to map PIO space with certain memory attributes (e.g. 
the PCI mmap code, drm, fbmem, acorn video).  None of the calls to 
pgprot_writecombine are in performance critical paths, so would making 
pgprot_writecombine into a machine vector would be ok?  Comments?

Thanks,
Jesse
