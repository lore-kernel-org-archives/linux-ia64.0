From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 16 Sep 2020 06:33:25 +0000
Subject: Re: [PATCH v3 1/3] mm: replace memmap_context by meminit_context
Message-Id: <20200916063325.GK142621@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200915121541.GD4649@dhcp22.suse.cz>
 <20200915132624.9723-1-ldufour@linux.ibm.com>
In-Reply-To: <20200915132624.9723-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>, mhocko@suse.com, linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Tue, Sep 15, 2020 at 03:26:24PM +0200, Laurent Dufour wrote:
> The memmap_context enum is used to detect whether a memory operation is due
> to a hot-add operation or happening at boot time.
> 
> Make it general to the hotplug operation and rename it as meminit_context.
> 
> There is no functional change introduced by this patch
> 
> Suggested-by: David Hildenbrand <david@redhat.com>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> ---
>  arch/ia64/mm/init.c    |  6 +++---
>  include/linux/mm.h     |  2 +-
>  include/linux/mmzone.h | 11 ++++++++---
>  mm/memory_hotplug.c    |  2 +-
>  mm/page_alloc.c        | 10 +++++-----
>  5 files changed, 18 insertions(+), 13 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read:
    https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html
for how to do this properly.

</formletter>
