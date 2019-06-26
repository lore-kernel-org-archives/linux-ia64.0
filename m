From: Michal Hocko <mhocko@kernel.org>
Date: Wed, 26 Jun 2019 13:54:50 +0000
Subject: Re: [PATCH 1/2] x86, numa: always initialize all possible nodes
Message-Id: <20190626135450.GW17798@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190212095343.23315-1-mhocko@kernel.org>
 <20190212095343.23315-2-mhocko@kernel.org>
 <34f96661-41c2-27cc-422d-5a7aab526f87@google.com>
 <20190502130031.GC29835@dhcp22.suse.cz>
In-Reply-To: <20190502130031.GC29835@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Barret Rhoden <brho@google.com>
Cc: linux-mm@kvack.org, Pingfan Liu <kernelfans@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>

On Thu 02-05-19 09:00:31, Michal Hocko wrote:
> On Wed 01-05-19 15:12:32, Barret Rhoden wrote:
> [...]
> > A more elegant solution may be to avoid registering with sysfs during early
> > boot, or something else entirely.  But I figured I'd ask for help at this
> > point.  =)
> 
> Thanks for the report and an excellent analysis! This is really helpful.
> I will think about this some more but I am traveling this week. It seems
> really awkward to register a sysfs file for an empty range. That looks
> like a bug to me.

I am sorry, but I didn't get to this for a long time and I am still
busy. The patch has been dropped from the mm tree (thus linux-next). I
hope I can revisit this or somebody else will take over and finish this
work. This is much more trickier than I anticipated unfortunately.

-- 
Michal Hocko
SUSE Labs
