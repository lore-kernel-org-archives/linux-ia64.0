From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 20 Jan 2005 02:43:24 +0000
Subject: Re: [PATCH] Convert acpiphp to use generic resource code
Message-Id: <20050120024324.GH25940@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050119185120.GE25940@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20050119185120.GE25940@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 19, 2005 at 06:14:32PM -0800, Rajesh Shah wrote:
> For this to work properly on i386 (and x86_64), we will need to
> port Matthew's other patch at 
> http://marc.theaimsgroup.com/?l=linux-ia64&m0614534704894&w=2
> to i386 too. This sets up the bus resources correctly for root
> bridges, and is needed for pci_bus_assign_resources() to work
> properly.

I found a problem when hotplugging a card with a PCI-PCI bridge on it.
I hope to have a solution tomorrow.

> I can take a crack at doing that, but I'm going to have to hunt
> around for an acpiphp capable i386 box too. I will also test this
> on a Tiger ia64 box.
> 
> Rajesh

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
