From: Michal Hocko <mhocko@kernel.org>
Date: Wed, 13 Feb 2019 16:18:32 +0000
Subject: Re: [PATCH v3 2/2] mm: be more verbose about zonelist initialization
Message-Id: <20190213161832.GT4525@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190212095343.23315-3-mhocko@kernel.org>
 <20190213094315.3504-1-mhocko@kernel.org>
 <1433a7e9-87b2-7e8d-a87d-dcffe486635c@intel.com>
In-Reply-To: <1433a7e9-87b2-7e8d-a87d-dcffe486635c@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Pingfan Liu <kernelfans@gmail.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>

On Wed 13-02-19 08:14:50, Dave Hansen wrote:
> On 2/13/19 1:43 AM, Michal Hocko wrote:
> > 
> > We have seen several bugs where zonelists have not been initialized
> > properly and it is not really straightforward to track those bugs down.
> > One way to help a bit at least is to dump zonelists of each node when
> > they are (re)initialized.
> 
> Were you thinking of boot-time bugs and crashes, or just stuff going
> wonky after boot?

Mostly boot time. I haven't seen hotplug related bugs in this direction.
All the issues I have seen so far is that we forget a node altogether
and it ends up with no zonelists at all. But who knows maybe we have
some hidden bugs where zonelists is initialized only partially for some
reason and there is no real way to find out.

> We don't have the zonelists dumped in /proc anywhere, do we?  Would that
> help?

I would prefer to not export such an implementation detail into proc

-- 
Michal Hocko
SUSE Labs
