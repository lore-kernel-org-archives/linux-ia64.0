From: Jes Sorensen <jes@sgi.com>
Date: Wed, 20 Dec 2006 09:46:40 +0000
Subject: Re: [patch 1/3] ia64: enable CONFIG_DEBUG_SPINLOCK_SLEEP
Message-Id: <45890680.5050001@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200612192104.kBJL4gfn010370@shell0.pdx.osdl.net>
In-Reply-To: <200612192104.kBJL4gfn010370@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andrew Morton wrote:
>> Please don't do this in the sn2 defconfig! Spin lock debugging totally
>> kills scalability. I'll end up with a ton of internal complaints over
>> the kernel not performing if this goes in :-(
> 
> Well you tell me how to stop ia64 developers from submitting stuff which
> has stupid bugs which instamanifest for everyone else?  It is not uncommon.

Beat them with a stick?

Seriously, not sure how to deal with it. I try and keep the
sn2_defconfig to match the actual hardware and my colleagues rely on
being able to build that. With spin lock debugging enabled we can barely
boot the system on medium to large boxes.

If you get stuff like that from someone with an sgi.com address, let me
know and I'll apply the clue 2x4.

Cheers,
Jes
