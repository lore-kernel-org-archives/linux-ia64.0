From: Horms <horms@verge.net.au>
Date: Thu, 21 Sep 2006 01:48:01 +0000
Subject: Re: [Patch] IA64 Kexec/Kdump patch for 2.6.18-rc6
Message-Id: <20060921014800.GB4673@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1158288948.2591.195.camel@linux-znh>
In-Reply-To: <1158288948.2591.195.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 20, 2006 at 09:42:53AM -0700, Luck, Tony wrote:
> > Tony, Nan Hai, do you have any thoughts on merging this
> > series into ia64 test? Its really far to big to be managed
> > as a single unit. I would be much more comfortable if
> > we could track small incremental changes. Even the diff
> > between the current and previous version (as below) is quite large.
> 
> I'm open to suggestions.  My current inclination is to abandon the
> existing kexec/kdump patches that are currently in my test tree[1] and
> replace them with the latest set of patches.  So a re-diff of all that
> is considered good against 2.6.18 would be ideal for that.

I believe that the patch that Nanhai posted a few days ago
is currently the best candidate we have. That could just
go straight in. Alternatively, I can easily make a
single patch that moves your test tree to that point without
having to revert the kexec patches that you have already merged.

> Breaking the patch into some smaller pieces would also be good,
> but I don't think this needs to be taken to extremes (just define
> a few basic areas and split the patch ... I don't thing it is
> worth spending days/weeks to split this into a sequence  of 37 individually
> crafted patches, with the kernel being fully functional at every
> one of the 36 intermediate points).

Understood. My main concern is being able to track changes moving forward.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

