From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 07 Mar 2005 16:50:35 +0000
Subject: Re: PCI Express
Message-Id: <20050307165035.GH28741@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 07, 2005 at 08:48:13AM -0800, Grant Grundler wrote:
> On Fri, Mar 04, 2005 at 05:42:08PM -0600, Colin Ngam wrote:
> > Are PCIE devices supported in ia64?
> 
> I'm having trouble with the word "supported".
> You have a PCI-E Bridge and firmware that can talk to it
> hooked up to an ia64 box?
> 
> Anyway, linux has some PCI-E support in the generic PCI code.

... and I wrote the ia64-specific bits to access extended PCI config space
through the SAL PCI accessors.  See PCI_SAL_EXT_ADDRESS().

Various PCIe features are in the process of being added.  It all depends
what you mean when you say "supported".

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
