From: Arun Sharma <arun.sharma@intel.com>
Date: Wed, 12 Nov 2003 19:53:01 +0000
Subject: Re: Odd IA32 mmap calls - Is this fixed
Message-Id: <marc-linux-ia64-106866691024263@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106862063402317@msgid-missing>
In-Reply-To: <marc-linux-ia64-106862063402317@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 11/12/2003 11:45 AM, n0ano@n0ano.com wrote:
> Arun-
> 
> I'm pretty sure your patch with cause things to break.  You
> will wind up freeing memory that the IA32 process is still
> using, causing `bad` things to happen.
> 

Yes, of course. May be the disclaimer wasn't prominent enough :)

> Actually, there is a solution but it's kind of icky.  The
> idea is you have to maintain knowledge of which 4K area of
> the IA32 prcesses's IA64 page is truly in use.  When all
> 4K areas of the IA64 page are freed you can free the IA64 page.
> 
> This not as bad as it could be because you only have to keep
> track of the first & last IA64 pages that are used for each
> IA32 mmap request so the overhead isn't that outrageous.  I
> submitted a patch to do this ages ago but I guess it got lost
> somehow.

Is this the patch you're talking about ?

http://www.gelato.unsw.edu.au/linux-ia64/0203/3099.html

	-Arun

