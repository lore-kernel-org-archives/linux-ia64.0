From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 22 Apr 2008 22:21:53 +0000
Subject: RE: [Patch 1/4] move XP and XPC to drivers/misc/sgi-xp -v4
Message-Id: <1FE6DD409037234FAB833C420AA843EC012AF549@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080422194459.GB13086@sgi.com> <20080422194656.GA14628@sgi.com> <1FE6DD409037234FAB833C420AA843EC012AF3D7@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC012AF3D7@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Dean Nelson <dcn@sgi.com>
Cc: jes@sgi.com, gregkh@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

> I applied this series on top of this morning's patch to change
> the uncached allocator to support multiple page allocations.

I've now dropped the change to the uncached allocator. You'll need
to update this patch with the changes to the users of 
uncached_{alloc,free}_page.

Using the older one-page version your patches to move XP and
XPC all apply, and I see no build errors (I don't have a system
on which to check that this works).

-Tony
