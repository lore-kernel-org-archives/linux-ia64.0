From: Joshua Aas <josha@sgi.com>
Date: Wed, 14 Jul 2004 16:17:39 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <40F55CA3.10706@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On Wed, Jul 14, 2004 at 10:44:31AM +0200, Andi Kleen wrote:
> 
>>Better would be probably to speed this up.
>>I bet most of the overhead comes from taking locks in free_pages.
>>How about adding a lockless ____free_pages and using that? 
>>Adding an more optimized path for this is also not out of the question.
>>Another way would be to increase the bootmem page size, but
>>this won't cut down the overhead of free_pages.
> 
> 
> That also sounds like an excellent idea.

Seems like a good idea to me too. I'll try to come up with a patch that doesn't do locking since it is early enough in the boot process, and maybe I can get rid of some looping/function calls too. This theoretical patch seems like a good idea in any case, but my progress patch might still be necessary on top of that since I'm not sure how much time it will actually save. On machines with 1-8TB of memory the wait might still be considerable (i.e. on the order of 3-8 minutes).

-- 
Josh Aas
Silicon Graphics, Inc. (SGI)
Linux System Software
651-683-3068
