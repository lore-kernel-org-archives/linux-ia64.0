From: Bob Picco <bob.picco@hp.com>
Date: Mon, 22 Aug 2005 14:20:36 +0000
Subject: Re: updated libunwind kernel patch
Message-Id: <20050822142036.GO8919@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea4305081514526149997a@mail.gmail.com>
In-Reply-To: <ed5aea4305081514526149997a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

david mosberger wrote:	[Mon Aug 15 2005, 05:52:14PM EDT]
> Attached below is an updated libunwind kernel patch relative to Tony's
> linux-2.6 git repository.  On the ia64-side, I just updated it
> slightly to account for minor changes in Tony's tree.  There is also
> the beginning of some x86-64 support (to demonstrate the portability
> of the API), but that code isn't ready for prime-time.  I haven't made
> a final decision on what to do about that.  On the one hand, I'd like
> to have libunwind support for more than one platform but on the other,
> there are some GCC issues which are standing in the way for libunwind
> being used as the primary unwinder on DWARF-based platforms (at least
> as of last time I checked) so I may still decide to push for an
> initial ia64-only version, since that's where we'd get the biggest
> benefit (single source tree which can be shared 95% with the
> user-level libunwind & lots of bug-fixes compared to the old kernel
> unwinder).
> 
>   --david
Hi David:

Any chance you can post the attachment?  It appears to be empty.

thanks,

bob
