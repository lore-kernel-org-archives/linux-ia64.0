From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 24 Jan 2006 17:33:16 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124173316.GA17352@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 24, 2006 at 10:02:35AM +0100, Ingo Molnar wrote:
> what's the problem with doing that? It's a single comparison [of two 
> values we already have accessed in that function!] and a rarely taken 
> branch in a single subarch of a single arch's switch_to() function. If 
> this use (of migration related arch functionality) becomes more 
> widespread then we can generalize it, but right now i just dont see the 
> point, given that the two solutions are almost totally equivalent in 
> terms of "overhead".

As coded the comparison wasn't inline, it was inside the machvec function,
so we'd have to make an indirect function call in order to make the
comparison and then do nothing most of the time.  I'd be happier with:

    if (unlikely(foo != bar)) /* migration */
	platform_switch_from(next);

But I'd also like to see how invasive a "task has migrated" bit in
thread_info.flags (as suggested elsewhere in this thread) gets to
be.

-Tony
