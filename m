From: Adrian Bunk <bunk@stusta.de>
Date: Tue, 07 Feb 2006 22:53:25 +0000
Subject: Re: [2.6 patch] IA64_GENERIC shouldn't select other stuff
Message-Id: <20060207225325.GE3524@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060207221157.GA3524@stusta.de> <9883.1139351831@ocs3> <20060207224344.GF1601@parisc-linux.org>
In-Reply-To: <20060207224344.GF1601@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Keith Owens <kaos@sgi.com>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Feb 07, 2006 at 03:43:44PM -0700, Matthew Wilcox wrote:
> On Wed, Feb 08, 2006 at 09:37:11AM +1100, Keith Owens wrote:
> > A generic IA64 kernel requires (at least) the ACPI and NUMA options in
> > order to run on all the IA64 platforms out there.  Omitting those
> > options and relying on the user to set them by hand is going to cause
> > more problems.
> 
> I'm not sure about that.  If the user selects a specific type of machine,
> ACPI doesn't get selected for them -- even when it's needed to boot.
> It's certainly inconsistent and should be fixed one way or the other.

And PCI is never selected for him with IA64_GENERIC.

I see the point for a catch-all option for processor-specific stuff, but 
it can't be a replacement for allyesconfig.

AFAIR your defconfig was intended for the "runs everywhere" case (with 
the exception that in this case the bug that CONFIG_ITANIUM is not set 
is still unfixed - would you accept a patch to fix this?).

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

