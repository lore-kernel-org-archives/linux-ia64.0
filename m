From: Nicholas Piggin <npiggin@gmail.com>
Date: Thu, 11 Jul 2019 10:30:00 +0000
Subject: Re: [RFC PATCH] mm: remove quicklist page table caches
Message-Id: <1562840680.snxfuzmtxv.astroid@bobo.none>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190711030339.20892-1-npiggin@gmail.com>
        <20190711082539.GC29483@dhcp22.suse.cz>
In-Reply-To: <20190711082539.GC29483@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org

Michal Hocko's on July 11, 2019 6:25 pm:
> On Thu 11-07-19 13:03:39, Nicholas Piggin wrote:
>> Remove page table allocator "quicklists". These have been around for a
>> long time, but have not got much traction in the last decade and are
>> only used on ia64 and sh architectures.
>> 
>> The numbers in the initial commit look interesting but probably don't
>> apply anymore. If anybody wants to resurrect this it's in the git
>> history, but it's unhelpful to have this code and divergent allocator
>> behaviour for minor archs.
>> 
>> Also it might be better to instead make more general improvements to
>> page allocator if this is still so slow.
> 
> Agreed. And if that is not possible for whatever reason then we have a
> proper justification for the revert at least.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks. If it's agreed with ia64 and sh maintainers, I can send
individual patches through their trees, then the removal patch
will be functionally a nop that can be easily pushed through.

Thanks,
Nick
