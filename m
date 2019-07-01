From: Michal Hocko <mhocko@kernel.org>
Date: Mon, 01 Jul 2019 10:27:56 +0000
Subject: Re: [PATCH v3 10/11] mm/memory_hotplug: Make unregister_memory_block_under_nodes() never fail
Message-Id: <20190701102756.GO6376@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-11-david@redhat.com>
 <20190701085144.GJ6376@dhcp22.suse.cz>
 <20190701093640.GA17349@linux>
In-Reply-To: <20190701093640.GA17349@linux>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-s390@vger.kernel.org, Alex Deucher <alexander.deucher@amd.com>, linux-ia64@vger.kernel.org, David Hildenbrand <david@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mark Brown <broonie@kernel.org>, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, "Rafael J. Wysocki" <rafael@kernel.org>, Igor Mammedov <imammedo@redhat.com>, akpm@linux-foundation.org, Chris Wilson <chris@chris-wilson.co.uk>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org

On Mon 01-07-19 11:36:44, Oscar Salvador wrote:
> On Mon, Jul 01, 2019 at 10:51:44AM +0200, Michal Hocko wrote:
> > Yeah, we do not allow to offline multi zone (node) ranges so the current
> > code seems to be over engineered.
> > 
> > Anyway, I am wondering why do we have to strictly check for already
> > removed nodes links. Is the sysfs code going to complain we we try to
> > remove again?
> 
> No, sysfs will silently "fail" if the symlink has already been removed.
> At least that is what I saw last time I played with it.
> 
> I guess the question is what if sysfs handling changes in the future
> and starts dropping warnings when trying to remove a symlink is not there.
> Maybe that is unlikely to happen?

And maybe we handle it then rather than have a static allocation that
everybody with hotremove configured has to pay for.
-- 
Michal Hocko
SUSE Labs
