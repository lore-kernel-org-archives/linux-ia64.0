From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 21 Dec 2004 18:39:47 +0000
Subject: Re: [PATCH] modifing vmemmap initialization [1/1] : modifies init sequence
Message-Id: <20041221183947.GB31261@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <41C7CC9E.7080602@jp.fujitsu.com>
In-Reply-To: <41C7CC9E.7080602@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 21, 2004 at 06:33:55PM +0000, Christoph Hellwig wrote:
> On Tue, Dec 21, 2004 at 04:20:29PM +0900, Hiroyuki KAMEZAWA wrote:
> > 
> > This patch adjust calling sequence of virtual_mem_map_alloc(),
> > which is added by previous patch.
> 
> This doesn't look like an improvement at all, the whole virtual memmap
> should not need core ifdefs.  In fact I still hope it'll go away.

It doesn't need core ifdefs at all -- simply define a dummy
virtual_mem_map_alloc() and you can remove the ifdefs.

(I also hope it'll go away.  Where's CONFIG_NONLINEAR got to?)

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
