From: Robin Holt <holt@sgi.com>
Date: Tue, 27 Apr 2004 10:52:28 +0000
Subject: Re: cacheble to uncachble change
Message-Id: <20040427105228.GA21811@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <408D5C58.E07A5FBE@email.mot.com>
In-Reply-To: <408D5C58.E07A5FBE@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Apr 26, 2004 at 05:03:23PM -0700, David Mosberger wrote:
> >>>>> On Mon, 26 Apr 2004 16:35:55 -0500, Robin Holt <holt@sgi.com> said:
> 
> 
> Are you just re-stating my caveat about memory-attribute-aliasing or
> are you saying something else?  If the latter, I'm not following.  If
> the former, I certainly agree: memory attribute-aliasing leads to
> really nasty-to-track-down bugs.  Hence, you want to make sure
> _upfront_ that it doesn't occur.

Restating.  Don't you love the person who plays the master of the obvious
role.  I started writing the email and was at the same time looking for
examples of kernel code from 2.4 which we had found that was speculating
addresses and was going to hopefully point out how difficult it was
for us to track down.  Unfortunately, I never found the bugs in our
internal bug tracking system.  I am not sure we ever actually found
the source of the corruption, only that it was occuring.

Sorry,
Robin Holt
