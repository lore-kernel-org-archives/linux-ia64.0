From: Matthew Wilcox <willy@debian.org>
Date: Wed, 07 Jan 2004 12:13:47 +0000
Subject: Re: FYI, ZX1 config problem in 2.4.23/2.4.24
Message-Id: <20040107121347.GA17182@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401061732.22576.bjorn.helgaas@hp.com>
In-Reply-To: <200401061732.22576.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 06, 2004 at 05:32:22PM -0700, Bjorn Helgaas wrote:
> When I changed the "HP-zx1" kernel config choice to just "HP",
> I seem to have exposed an oddity in the way menuconfig works.
> The menu contains this:
> 
>         "generic                CONFIG_IA64_GENERIC             \
>          DIG-compliant          CONFIG_IA64_DIG                 \
>          HP-simulator           CONFIG_IA64_HP_SIM              \
>          HP                     CONFIG_IA64_HP_ZX1              \
>          SGI-SN2                CONFIG_IA64_SGI_SN2" generic
> 
> and apparently when the user selects "HP", menuconfig turns on
> the *simulator* symbol (CONFIG_IA64_HP_SIM) instead of the HP_ZX1
> symbol.  I think this looks like a menuconfig bug, but the easiest
> way around it is probably to use a patch like this:

I think another way to do it would be to move HP_ZX1 above HP_SIM.
But aesthetically, we should probably put the simulator option down at
the bottom anyway.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
