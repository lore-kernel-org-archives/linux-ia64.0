From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 19 Jan 2005 18:16:00 +0000
Subject: RE: pgprot_writecombine & shub 1.x
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02C000AA@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Oh, I thought I said that in the first message, I'm talking 
>about I/O memory here.  In any event though, we shouldn't be
>mapping anything with the WC attribute that the EFI memory
>map doesn't allow.

Does the EFI memory map help here?  Is I/O memory included
in the efi memory map?  What about the hot-plug case ... the
EFI memory map isn't updated for new i/o memory that appears
when you plug in a new card?

-Tony
