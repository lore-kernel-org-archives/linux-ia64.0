From: William Lee Irwin III <wli@holomorphy.com>
Date: Fri, 06 Aug 2004 14:17:55 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <20040806141755.GH17188@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Aug 06, 2004 at 09:11:50AM -0500, Josh Aas wrote:
> Attached is an improved version of Tony Luck's patch. It shaves another 
> ~25% off by not using atomic ops to clear the page reserved bits and 
> prefetching. Tony - will you sign off on it with me and we'll get this in?
> Unfortunately, this still leaves a ~1 minute delay with no indication of 
> what is going on for 4TB machines, and ~2 minutes for 8TB. Thus, I'd 
> still like to see my progrees indicator patch go in. I am guessing 
> memory sizes are only going to get bigger than even 8 TB, and memory is 
> not going to get faster at the rate the totals increase (it certainly 
> didn't double in speed between 4 and 8 TB installations). Thoughts?
> Signed-off-by: Josh Aas <josha@sgi.com>

There are still stronger attacks on this problem. I'll go about porting
one or more of those up to current. (The one I'm favoring at the moment
has actually never had broad exposure in the past).

This will be a time-consuming affair, so it will be fine to merge
things like this in the interim. I would give an ETA of several weeks
for an initial release, largely for testing on a sufficiently broad
variety of architectures beforehand.


-- wli
