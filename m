From: Christoph Hellwig <hch@lst.de>
Date: Tue, 05 Feb 2008 09:49:25 +0000
Subject: Re: [patch 4/4] ia64: fix ptrace inside a namespace
Message-Id: <20080205094925.GA10476@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802050742.m157gjIG010223@imap1.linux-foundation.org>
In-Reply-To: <200802050742.m157gjIG010223@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 04, 2008 at 11:43:04PM -0800, akpm@linux-foundation.org wrote:
> From: Pavel Emelyanov <xemul@openvz.org>
> 
> The ia64 has its own sys_ptrace implementation and it was overlooked when the
> pid namespaces patches were sent.
> 
> Use find_task_by_vpid() in it

The plan is to kill this code entirely and make ia64 look like other
ptrace implementations.  Please double check this doesn't cause merge
issues with the hopefully pending rewrite of the ia64 ptrace code.

