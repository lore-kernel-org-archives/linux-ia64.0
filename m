From: Daniel Phillips <phillips@istop.com>
Date: Sat, 28 Aug 2004 21:41:36 +0000
Subject: Re: page fault scalability patch final : i386 tested, x86_64 support added
Message-Id: <200408281741.36211.phillips@istop.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408151924250.4480@schroedinger.engr.sgi.com> <20040827173641.5cfb79f6.akpm@osdl.org> <20040828010253.GA50329@muc.de>
In-Reply-To: <20040828010253.GA50329@muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@muc.de>
Cc: Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@davemloft.net>, clameter@sgi.com, ak@suse.de, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, benh@kernel.crashing.org, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

Hi Andi,

On Friday 27 August 2004 21:02, Andi Kleen wrote:
> Yep.  Good plan. atomic_long_t ?

Would it not be more C-ish as long_atomic_t?

Regards,

Daniel
