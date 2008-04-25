From: Dean Nelson <dcn@sgi.com>
Date: Fri, 25 Apr 2008 18:56:04 +0000
Subject: Re: [Patch 1/4] move XP and XPC to drivers/misc/sgi-xp -v4
Message-Id: <20080425185604.GB13773@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080422194459.GB13086@sgi.com> <20080422194656.GA14628@sgi.com> <1FE6DD409037234FAB833C420AA843EC012AF3D7@orsmsx424.amr.corp.intel.com> <1FE6DD409037234FAB833C420AA843EC012AF549@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC012AF549@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: jes@sgi.com, gregkh@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, Apr 22, 2008 at 03:21:53PM -0700, Luck, Tony wrote:
> > I applied this series on top of this morning's patch to change
> > the uncached allocator to support multiple page allocations.
> 
> I've now dropped the change to the uncached allocator. You'll need
> to update this patch with the changes to the users of 
> uncached_{alloc,free}_page.

Sorry for not responding sooner, but I've been on vacation (and still am)
and wasn't reading email.

Thanks for dropping the uncached allocator patch in favor of the patchset
that moves XPC/XPNET to drivers/misc/sgi-xp.

I've just submitted a new version of the uncached allocator patch that
includes the changes to drivers/misc/sgi-xp/xpc_partition.c necesssary
for the system to build cleanly. (Sorry about that.)

> Using the older one-page version your patches to move XP and
> XPC all apply, and I see no build errors (I don't have a system
> on which to check that this works).

Doing what you did did result in a functioning XPC kernel module. Thanks.
