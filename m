From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 08 Oct 2003 22:45:16 +0000
Subject: Re: [PATCH 2.6.0test5: 2 of 3] MCA/TLB recovery
Message-Id: <marc-linux-ia64-106565324405947@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106522368223247@msgid-missing>
In-Reply-To: <marc-linux-ia64-106522368223247@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 08, 2003 at 03:39:45PM -0700, David Mosberger wrote:
> >>>>> On Wed, 8 Oct 2003 14:44:04 -0700, "Luck, Tony" <tony.luck@intel.com> said:
> 
>   Tony> Any comments on parts 1 & 3???
> 
> I'm still catching up with my mail backlog, so I didn't have time to
> look at it very carefully, but from what I saw, they looked fine to
> me.  The big issue now, of course, is that Linus wants to be in
> bug-fix-only, so the cosmetic fixes would have to be removed from the
> patch before I can accept it.

Really, even for ia64 code?  Does that mean all the changes I've
recently pushed you will be dropped?  What about the fix for
CONFIG_DISCONTIGMEM + CONFIG_VIRTUAL_MEM_MAP that I've been working so
hard to clean up?

Thanks,
Jesse
