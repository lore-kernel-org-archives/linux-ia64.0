From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 06 May 2004 14:09:33 +0000
Subject: Re: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <20040506150933.A17112@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <003801c43347$812a1590$39624c0f@india.hp.com> <20040506114414.A14543@infradead.org> <20040506115919.GZ2281@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040506115919.GZ2281@parcelfarce.linux.theplanet.co.uk>; from willy@debian.org on Thu, May 06, 2004 at 12:59:19PM +0100
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@debian.org>
Cc: Sourav Sen <souravs@india.hp.com>, Matt_Domsch@dell.com, matthew.e.tolentino@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, May 06, 2004 at 12:59:19PM +0100, Matthew Wilcox wrote:
> It's not exactly modifiable.  I'm not sure what benefit we'd gain from
> splitting this file into dozens.

a consistant interface.  If we support gazillion random formats in sysfs
it's no gain at all over the old procfs mess.
