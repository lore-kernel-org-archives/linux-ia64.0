From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 09 May 2008 21:03:19 +0000
Subject: Re: [PATCH 3/3] ia64: Call migration code on correctable errors v3
Message-Id: <Pine.LNX.4.64.0805091358160.20375@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080509151135.GD16523@sgi.com>
In-Reply-To: <20080509151135.GD16523@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>

On Fri, 9 May 2008, Russ Anderson wrote:

> +	local_irq_save(irq_flags);

The page migration functions expect to be called in non atomic contexts 
since they use things like lock_page(). Can you just drop the irq disable? 
The spinlock should not be there either. Page migration serialize via 
the LRU. Pages that are to be migrated have to be taken off the LRU 
first. There is no danger of two threads trying to migrate the same 
page because the second one will not be able to take it off the LRU 
anymore.



