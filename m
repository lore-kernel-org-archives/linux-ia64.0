From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 30 Jul 2003 09:21:10 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105955706014282@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 29, 2003 at 11:34:07AM -0700, Christopher Wedgwood wrote:
> 	count = (end - start) >> PAGE_SHIFT;
> 	bytes = sizeof(struct node_fetchops) + count/8;
> 	fops = vmalloc(bytes);
> 	memset(fops, 0, bytes);

vmalloc can fail..

