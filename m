From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 25 Mar 2008 22:49:46 +0000
Subject: RE: [Patch 0/5] prepare XPC and XPNET to support SGI UV
Message-Id: <1FE6DD409037234FAB833C420AA843ECE9E1AB@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080325192524.343385569@attica.americas.sgi.com> <20080325201423.GB4446@sgi.com>
In-Reply-To: <20080325201423.GB4446@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dean Nelson <dcn@sgi.com>, jes@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, Mar 25, 2008 at 02:25:24PM -0500, dcn@sgi.com wrote:
> This set of five patches moves XPC and XPNET to drivers/misc/xp in preparation
> for enabling X86_64 support.

Part 2 (which I got since you addressed it to me directly as well as
to the list) has a couple of "Space in indent is follwed by a tab"
complaints from GIT.  Part 3 has one too.  Apart from that all five
parts apply and the build is clean on all my configs.  Boots on the
tiger (but this doesn't constitute a review ... just a "you didn't
break anything unrelated while making this change").

> The missing patch moved XPC and XPNET from arch/ia64/sn to drivers/misc/xp.
> How should such a patch be submitted?

I think git has an option to produce its own brand of diff output
that lists the renames without doing a full remove & add which is
needed for patch(1) comprehensibility.  A few minutes staring at
git documentation hasn't revealed what that option is though :-(

For purposes of getting someone to review ... you could hand edit
to show the renames as:

	$ mv arch/ia64/sn/kernel/xpc_channel.c drivers/misc/xp/xpc_channel.c
		... etc.

and just include the diffs for the Makefiles, Kconfig etc.

Or break part 2 into:

	2a - remove driver from arch/ia64
	2b - add driver to drivers/misc/xp

-Tony
