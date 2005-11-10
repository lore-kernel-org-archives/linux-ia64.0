From: Dean Roe <roe@sgi.com>
Date: Thu, 10 Nov 2005 16:19:37 +0000
Subject: Re: [PATCH] - Make pfn_valid more precise for SGI Altix systems
Message-Id: <20051110161937.GA7244@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051109202506.GA4152@sgi.com>
In-Reply-To: <20051109202506.GA4152@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 09, 2005 at 03:34:46PM -0800, Luck, Tony wrote:
> Ignore earlier message ... I thought I saw a || when you really
> just have && all the way through this:
> 
> +# define pfn_valid(pfn)		(((pfn) >= min_low_pfn) && ((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
> 
> Doesn't that mean that you are optimizing for the case where some
> one passed in a bad pfn ... does that really happen a lot?
> 
> -Tony

Well, as much as the check against max_low_pfn was optimizing for the
other end.  This does occur on Altix systems when processes access memory
on other partitions (you probably saw Jack and Robin's comments about this
in the 4-level page table thread today).  I'm not sure if there are many
cases other than that, although I did notice that some of the other
architecture definitions do a similar check.

Dean

-- 
Dean Roe
Silicon Graphics, Inc.
roe@sgi.com
