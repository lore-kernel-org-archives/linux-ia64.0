From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 21 Dec 2004 18:33:55 +0000
Subject: Re: [PATCH] modifing vmemmap initialization [1/1] : modifies init sequence
Message-Id: <20041221183355.GA32413@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <41C7CC9E.7080602@jp.fujitsu.com>
In-Reply-To: <41C7CC9E.7080602@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 21, 2004 at 04:20:29PM +0900, Hiroyuki KAMEZAWA wrote:
> 
> This patch adjust calling sequence of virtual_mem_map_alloc(),
> which is added by previous patch.

This doesn't look like an improvement at all, the whole virtual memmap
should not need core ifdefs.  In fact I still hope it'll go away.

