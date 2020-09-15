From: Oscar Salvador <osalvador@suse.de>
Date: Tue, 15 Sep 2020 10:28:51 +0000
Subject: Re: [PATCH v3 1/3] mm: replace memmap_context by memplug_context
Message-Id: <20200915102845.GA30015@linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200915094143.79181-1-ldufour@linux.ibm.com>
 <20200915094143.79181-2-ldufour@linux.ibm.com>
In-Reply-To: <20200915094143.79181-2-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, David Hildenbrand <david@redhat.com>, mhocko@suse.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Tue, Sep 15, 2020 at 11:41:41AM +0200, Laurent Dufour wrote:
> The memmap_context is used to detect whether a memory operation is due to a
> hot-add operation or happening at boot time.
> 
> Make it general to the hotplug operation and rename it at memplug_context.
> 
> There is no functional change introduced by this patch
> 
> Suggested-by: David Hildenbrand <david@redhat.com>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3
