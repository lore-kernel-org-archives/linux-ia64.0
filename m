From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 12 Mar 2002 03:08:30 +0000
Subject: Re: [Linux-ia64] [PATCH] agpgart/DRM page_mask
Message-Id: <marc-linux-ia64-105590701905244@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905236@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905236@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  Bjorn> I'd like to propose putting the attached patch into the IA64
  Bjorn> tree.  The point is to be able to support both 460GX and a
  Bjorn> similar HP chipset without having to put kludges in DRM.

  Bjorn> Chris Ahna and Jeff Hartmann both seem to be OK with this
  Bjorn> approach.  It's not really IA64-specific, and I did try to
  Bjorn> get it directly into 2.4.x/2.5.x, but there's really no
  Bjorn> benefit there without the 460GX GART code.  So it makes sense
  Bjorn> to me to keep it with the 460GX code, and merge both into the
  Bjorn> main tree at the same time.  -- Bjorn Helgaas -
  Bjorn> bjorn_helgaas@hp.com Linux Systems Operation R&D
  Bjorn> Hewlett-Packard

The patch looks good to me and I applied it both on the 2.4 and 2.5
trees.  Chris, I assume you'll be working on pushing this into the
official trees?

	--david

