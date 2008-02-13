From: Robin Holt <holt@sgi.com>
Date: Wed, 13 Feb 2008 15:03:05 +0000
Subject: Re: [PATCH] Reduce per_cpu allocations to the minimum needed for
Message-Id: <20080213150305.GV3875@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080211175918.GO3875@sgi.com>
In-Reply-To: <20080211175918.GO3875@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 13, 2008 at 07:19:48AM -0600, Robin Holt wrote:
> 
> Again, hold off on this.  I have found certain CONFIG settings which are
> causing an MCA immediately after /sbin/init is exec'd.  Not sure if it
> is my patch yet or not.
> 
> Sorry for the confusion,
> Robin

I found the problem.  I will post a corrected patchset shortly.  I still
need to test-boot on additional configuration before I do that.  It was
not because of this patch, but I am going to put the fix before this
patch and it does affect this patch's ability to apply cleanly.

Thanks,
Robin
