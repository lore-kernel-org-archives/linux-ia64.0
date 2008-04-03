From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 03 Apr 2008 18:42:40 +0000
Subject: RE: [Patch 0/3] Modify how per_cpu allocations are done. -V8
Message-Id: <1FE6DD409037234FAB833C420AA843ECFD7EC4@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080213175519.892353127@attica.americas.sgi.com>
In-Reply-To: <20080213175519.892353127@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Can you give me some direction on this?  I think the first two patches
> are probably in the ball park of what we should take.  The third (MCA
> stack allocations) should probably be dropped.  I would like to get one
> final (hopefully) set out before the merge window opens.

Yes.  The first two patched will be good to have in the next merge.
The MCA allocation one felt like we moved the furniture around a
bit, but it didn't look like a real improvement.

If you repost the first two, then it will save me digging back in the
archives.

-Tony
