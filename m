From: Matthew Wilcox <willy@debian.org>
Date: Fri, 16 Jan 2004 23:35:38 +0000
Subject: Re: [PATCH] Kconfig cleanup, part 1
Message-Id: <20040116233538.GA14872@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401161136.37066.bjorn.helgaas@hp.com>
In-Reply-To: <200401161136.37066.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jan 16, 2004 at 11:36:37AM -0700, Bjorn Helgaas wrote:
> I'd really like to do a more extensive cleanup along the lines of
> Matthew Wilcox's patch:
> 
>     http://linux.bkbits.net:8080/linux-2.5/cset@1.1296.78.7
> 
> but I'm not sure how people feel about this during 2.6.  I guess if
> we want to do it at all in 2.6, sooner's better than later.  For a
> sample of what the cleaned-up version looks like, try:

I'm working towards this on several architectures.  A large part of this
is marking options as "depends on PCI" and "depends on X86" so that the
simulator targets (Ski, uml, etc) can use the generic drivers/Kconfig.
That work's going in through the kernel-janitors tree at the moment.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
