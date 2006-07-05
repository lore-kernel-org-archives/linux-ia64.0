From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 05 Jul 2006 19:16:41 +0000
Subject: RE: [PATCH] ia64, kexec: allow base of crashkernel to be auto-discovered
Message-Id: <617E1C2C70743745A92448908E030B2A3000B6@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060628110052.GA11751@verge.net.au>
In-Reply-To: <20060628110052.GA11751@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I might be confused, but I'm not exactly sure that my patch would run
> into this problem. It only tries to insert the "Crash kernel" resource
> as a sub-resource of an existing "System RAM" resource, and does so in
> such a way that it should not overlap with any existing sub-resources.
> Surely VGA and the like are in completely different resources not
> covered by a "System RAM" resource.

The problem is that _nearby_ resources may require different attributes,
yet be mapped by a single TR entry.  E.g. on an Intel Tiger there is a
"System RAM" resource from 0x100000-0x3ffffff, but if you place the kernel
image into it, then ITR[0] and DTR[0] will map the entire 64M from
0x0 to 0x3ffffff, which includes the VGA.

-Tony
