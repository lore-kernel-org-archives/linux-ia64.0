From: Oscar Salvador <osalvador@suse.de>
Date: Tue, 15 Sep 2020 10:33:27 +0000
Subject: Re: [PATCH v3 3/3] mm: don't panic when links can't be created in sysfs
Message-Id: <20200915103327.GC30015@linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200915094143.79181-1-ldufour@linux.ibm.com>
 <20200915094143.79181-4-ldufour@linux.ibm.com>
In-Reply-To: <20200915094143.79181-4-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, David Hildenbrand <david@redhat.com>, mhocko@suse.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Tue, Sep 15, 2020 at 11:41:43AM +0200, Laurent Dufour wrote:
> At boot time, or when doing memory hot-add operations, if the links in
> sysfs can't be created, the system is still able to run, so just report the
> error in the kernel log rather than BUG_ON and potentially make system
> unusable because the callpath can be called with locks held.
> 
> Since the number of memory blocks managed could be high, the messages are
> rate limited.
> 
> As a consequence, link_mem_sections() has no status to report anymore.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: David Hildenbrand <david@redhat.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3
