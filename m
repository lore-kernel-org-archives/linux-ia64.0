From: James E Wilson <wilson@specifixinc.com>
Date: Mon, 07 Feb 2005 22:18:27 +0000
Subject: Re: PATCH: Fix 2.6 kernel ia64 directives
Message-Id: <1107814707.9243.89.camel@aretha.corp.specifixinc.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050202221918.GA7973@lucon.org>
In-Reply-To: <20050202221918.GA7973@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2005-02-07 at 12:11, James E Wilson wrote:
> On Wed, 2005-02-02 at 14:50, David Mosberger wrote:
> > While I'm in favor of fixing such typos, the Itanium Assembly Language
> > Reference Manual states:

I see Jan responded to this already.  I missed it earlier because it
didn't thread with the rest of the discussion.  I also see that this
discussion has moved to the binutils list, so I will continue it there.

I see I was wrong about IAS giving an error for mismatched proc/end, I
misunderstood why that change was made.  The rest of the message should
still be accurate.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com


