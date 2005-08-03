From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Wed, 03 Aug 2005 19:57:17 +0000
Subject: RE: xen patch
Message-Id: <516F50407E01324991DD6D07B0531AD55F6518@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F040F7016@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F040F7016@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> From: Luck, Tony [mailto:tony.luck@intel.com] 
> Sent: Wednesday, August 03, 2005 12:16 PM
> To: Magenheimer, Dan (HP Labs Fort Collins)
> Cc: linux-ia64@vger.kernel.org
> Subject: xen patch
> 
> Dan,
> 
> Can you send me <asm/xen/privop.h> so I can see where all
> this indirection is leading to?

OK, it's not quite ready for primetime but take a look at:

http://xenbits.xensource.com/ext/xenlinux-ia64-2.6.12.hg?cmd=file;fileno
de.f68fa5385f2dcd1610f67dbfcee0d3d2c7bb37;file=include/asm-ia64/xen/pr
ivop.h 

(If this hg link is problematic, let me know and I will send it
as an attachment.)

> Like David Mosberger I'm a bit sceptical about the need to replace
> constructs like:
> 
> 	ia64_getreg(_IA64_REG_AR_EFLAG)
> 
> with
> 	ia64_get_eflag()
> 
> but I can't see the whole picture at the moment.

Well, with both Tony and David voting for this, I will just
try to regen the patch to avoid replacing those constructs.

It looks like I will have to either move the extra level of
abstraction to several define's in both gcc_intrin.h and
intel_intrin.h -- or use an #ifdef __INTEL_COMPILER in
xen/privop.h.  Any preference which approach is better?

Thanks,
Dan
