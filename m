From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 09 May 2003 19:30:36 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705707@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 09, 2003 at 11:25:29AM -0700, David Mosberger wrote:
> I'm not sure.  I got the impression Tony may be looking at the virtual
> remapping in region 5.  I haven't heard whether text replication
> turned out to be important for 8870, but I'm starting to lean towards
> virtual remapping because it is more versatile (can handle both
> "strange" physical memory layouts and kernel replication).  This,
> coupled with the fact that it doesn't break any of the existing tools
> makes it pretty compelling.  Also, my primary objection about making
> the kernel model more complicated doesn't hold much water if we move
> everything to region 5.
> 
> Would there be a downside to this on SGI's machines?

Not that I can see--we've been using that method for awhile now with
good success, and I'd be happy to test any 2.5 patches that implement
this feature.  So I guess we should go with virtual remapping?  Tony?

Thanks,
Jesse

