From: Matthew Wilcox <willy@debian.org>
Date: Sat, 17 Jan 2004 00:18:12 +0000
Subject: Re: [PATCH] Kconfig cleanup, part 1
Message-Id: <20040117001812.GA16779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401161136.37066.bjorn.helgaas@hp.com>
In-Reply-To: <200401161136.37066.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jan 16, 2004 at 05:03:55PM -0700, Bjorn Helgaas wrote:
> On Friday 16 January 2004 4:35 pm, Matthew Wilcox wrote:
> > I'm working towards this on several architectures.  A large part of this
> > is marking options as "depends on PCI" and "depends on X86" so that the
> > simulator targets (Ski, uml, etc) can use the generic drivers/Kconfig.
> > That work's going in through the kernel-janitors tree at the moment.
> 
> OK, I'll wait for that.  Sounds like it will at least become much easier,
> and maybe you'll even do it for me ;-)

Oh, I'm happy to.  ia64 is high on my list of architecture Kconfig files
to shrink to their minimum possible size (and align with x86 as much
as possible).

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
