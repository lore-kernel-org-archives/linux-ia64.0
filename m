From: Matthew Wilcox <willy@debian.org>
Date: Tue, 23 Mar 2004 03:04:39 +0000
Subject: Re: hardware random number generator?
Message-Id: <20040323030439.GR25059@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <405F9A2E.8040509@pobox.com>
In-Reply-To: <405F9A2E.8040509@pobox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 22, 2004 at 09:00:14PM -0500, Jeff Garzik wrote:
> Matthew Wilcox wrote:
> >config HW_RANDOM
> >        tristate "Intel/AMD/VIA HW Random Number Generator support"
> >        depends on (X86 || IA64) && PCI
> >        ---help---
> >          This driver provides kernel-side support for the Random Number
> >          Generator hardware found on Intel i8xx-based motherboards,
> >          AMD 76x-based motherboards, and Via Nehemiah CPUs.
> >
> >Why IA64 too?  This file contains the code:
> 
> No idea.  <guessing>  There are some Intel ICH-based motherboards w/ 
> IA64 chips on them, maybe?  I certainly don't recall adding that IA64 
> marker... :)

Heh.  ICH is x86-only, as far as I know.  Intel did the 460GX chipset
for Merced and now have the E8870 chipset for McKinley/Madison.  Anyone
familiar with the Intel chipsets want to comment about the presence or
absence of a RNG?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
