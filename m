From: Matthew Wilcox <willy@debian.org>
Date: Thu, 06 May 2004 11:59:19 +0000
Subject: Re: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <20040506115919.GZ2281@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <003801c43347$812a1590$39624c0f@india.hp.com> <20040506114414.A14543@infradead.org>
In-Reply-To: <20040506114414.A14543@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>, Sourav Sen <souravs@india.hp.com>, Matt_Domsch@dell.com, matthew.e.tolentino@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, May 06, 2004 at 11:44:14AM +0100, Christoph Hellwig wrote:
> On Thu, May 06, 2004 at 02:22:46PM +0530, Sourav Sen wrote:
> > Hi,
> > 
> > The following simple patch creates a read-only file
> > "memmap" under <mount point>/firmware/efi/ in sysfs
> > and exposes the efi memory map thru it.
> 
> doesn't exactly fit into the one value per file approach, does it?

It's not exactly modifiable.  I'm not sure what benefit we'd gain from
splitting this file into dozens.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
