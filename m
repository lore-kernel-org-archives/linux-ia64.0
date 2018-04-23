From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 23 Apr 2018 17:15:55 +0000
Subject: Re: ia64 platform selection
Message-Id: <20180423171554.l75vqrxxtmkaic77@agluck-desk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180423134738.GA19816@infradead.org>
In-Reply-To: <20180423134738.GA19816@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Apr 23, 2018 at 06:47:38AM -0700, Christoph Hellwig wrote:

Hi Christoph,

> Do you know if there are any users left running kernel optimized for
> a specific platform, or if we can make the generic support the only
> available option.

I don't have any of the "specific" platforms that still work. So
although I build test for them, I only boot test a generic kernel.
So they may be broken for all I know.  If it makes your life easier
then by all means delete them.

> Also I'm curious if we have users of the SKI simulator left - it comes
> with various pretty bad device drivers, so removing it would probably
> make a few subsystem maintainers happy.

I ran into someone recently (in the past year) that was still using SKI.
If they make a noise here and want to keep it, then we should probably
do so, otherwise I won't be sad if you send a patch to delete it.

-Tony
