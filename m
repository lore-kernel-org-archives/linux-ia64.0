From: Matthew Wilcox <willy@debian.org>
Date: Fri, 24 Oct 2003 16:49:29 +0000
Subject: Re: Itanium2@900MHz slower than alpha@666MHz ?
Message-Id: <marc-linux-ia64-106701452429692@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106700871121653@msgid-missing>
In-Reply-To: <marc-linux-ia64-106700871121653@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 24, 2003 at 06:26:55PM +0200, Ionut Georgescu wrote:
> Yes, it is a 1.5MB cache CPU.
> 
> But it might be more than just cache misses. When running with a 256x256
> grid, I am actually using 3 256x257 matrices, which is slightly over
> 1.5MB.  I just made a comparison with a 32x32 grid and the difference is
> the same: alpha 10.294s, zx2000 14.777s . -O3 is only by 0.4s faster
> than -O2 in this case.
> 
> The variations are within +-0.02s between runs (for the 32x32 case).
> 
> Is there a way to test the bandwidth of the cache ? Because I think the
> alphas have actually 2MB of L2 cache, not L3.

I don't know about testing cache bandwidth, but /proc/pal/cpu0/cache_info
gives various stats on how the different levels of cache play together
on ia64.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
