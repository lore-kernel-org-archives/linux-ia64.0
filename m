From: William Lee Irwin III <wli@holomorphy.com>
Date: Wed, 14 Jul 2004 09:19:38 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <20040714091938.GN3411@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At some point in the past, someone wrote:
>> Freeing boot memory... done
>> It prints more dots every x nodes handled based on the total number of 
>> nodes, in such a way that the line never exceeds 80 chars. This way it is 
>> possible to see progress being made. I have tested this on a few machines, 
>> including a 512p/512GB machine, and it works fine.

On Wed, Jul 14, 2004 at 10:44:31AM +0200, Andi Kleen wrote:
> Better would be probably to speed this up.
> I bet most of the overhead comes from taking locks in free_pages.
> How about adding a lockless ____free_pages and using that? 
> Adding an more optimized path for this is also not out of the question.
> Another way would be to increase the bootmem page size, but
> this won't cut down the overhead of free_pages.

That also sounds like an excellent idea.


-- wli
