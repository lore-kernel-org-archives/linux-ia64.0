From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 22 Sep 2004 21:25:57 +0000
Subject: RE: rename generic_defconfig to defconfig?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F020ECECD@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409221713.12673.jbarnes@engr.sgi.com>
In-Reply-To: <200409221713.12673.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Just thought I'd float the idea of making the ia64 defconfig 
>into a generic ia64 kernel config.  It's probably easiest just
>to rename generic_defconfig to defconfig since that already
>works everywhere (well, except for akpm's box apparently).
>That would make it extra easy to build a working kernel for
>the various ia64 boxes out there...

Sounds plausible.  I'd also like to keep some more system
specific config files updated as well (to make it easier to
see which combinations of NUMA/DISCONTIG/VIRTUAL_MEM_MAP are
being used ... and thus try to avoid changes that prevent
them from even building).

Does anyone have a zx1_defconfig that works for 2.6.9-rc2?
I just tried to use the current one to rebuild for my zx2000
and the kernel made the system sing like a shortwave radio
without printing a single character to the screen :-(

-Tony
