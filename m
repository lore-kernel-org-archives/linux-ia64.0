From: Russ Anderson <rja@sgi.com>
Date: Fri, 24 Jun 2005 21:36:02 +0000
Subject: Re: [patch] Memory Error Handling Improvement
Message-Id: <200506242136.j5OLa2p8933745@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> 
>   >> Fine, but what about stores?
> 
>   Tony> Stores have too many extra levels of buffering to have much
>   Tony> hope.  But just because we can't help the store case doesn't
>   Tony> mean that we shouldn't do something about the load case.
> 
> Fine, but what about my suggestion of just presuming that the access
> came for user-level unless you can prove otherwise?

The key question is how to prove otherwise. 

Ironicly, my concern was this patch would be seen as too aggressive and
therefore risky.  So the patch is limited to the interrupt case, which
seemed to be a heavy hitter in testing.  I hadn't expected pushback for 
not being aggressive enough.  :-)

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
