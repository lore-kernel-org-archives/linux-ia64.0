From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 22 Sep 2004 23:25:23 +0000
Subject: RE: rename generic_defconfig to defconfig?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F020ECFEF@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409221713.12673.jbarnes@engr.sgi.com>
In-Reply-To: <200409221713.12673.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>I'm pretty sure CONFIG_VIRTUAL_MEM_MAP isn't needed either.  
>Also, which 
>device drivers did you have to tweak?  Should those changes 
>also go into 
>generic_defconfig?

Tigers with more than 2G of memory have a hole in the physical
address space (from 2G to 4G) reserved for memory mapped I/O.
So VIRTUAL_MEM_MAP (or I suppose DISCONTIG) is needed to avoid
wasting memory on page structs for non-existant memory.

The device driver bits are changing 'M' to 'Y' on devices. Like
Bjorn I'm too lazy to mess with modules on every build.

-Tony
