From: Andi Kleen <ak@suse.de>
Date: Wed, 14 Jul 2004 08:44:31 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <20040714084431.GC14642@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> Freeing boot memory... done
> 
> It prints more dots every x nodes handled based on the total number of 
> nodes, in such a way that the line never exceeds 80 chars. This way it is 
> possible to see progress being made. I have tested this on a few machines, 
> including a 512p/512GB machine, and it works fine.

Better would be probably to speed this up.

I bet most of the overhead comes from taking locks in free_pages.
How about adding a lockless ____free_pages and using that? 
Adding an more optimized path for this is also not out of the question.

Another way would be to increase the bootmem page size, but
this won't cut down the overhead of free_pages.

-Andi
