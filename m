From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Fri, 07 Sep 2018 08:42:12 +0000
Subject: Re: [RFC PATCH 07/29] memblock: remove _virt from APIs returning virtual address
Message-Id: <20180907084211.GA19153@rapoport-lnx>
List-Id: <linux-ia64.vger.kernel.org>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-8-git-send-email-rppt@linux.vnet.ibm.com>
 <CABGGiswdb1x-=vqrgxZ9i2dnLdsgtXq4+5H9Y1JRd90YVMW69A@mail.gmail.com>
 <20180905172017.GA2203@rapoport-lnx>
 <20180906072800.GN14951@dhcp22.suse.cz>
 <20180906124321.GD27492@rapoport-lnx>
 <20180906130102.GY14951@dhcp22.suse.cz>
 <20180906133958.GM27492@rapoport-lnx>
 <20180906134627.GZ14951@dhcp22.suse.cz>
In-Reply-To: <20180906134627.GZ14951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: Rob Herring <robh@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, mingo@redhat.com, Michael Ellerman <mpe@ellerman.id.au>, paul.burton@mips.com, Thomas Gleixner <tglx@linutronix.de>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Sep 06, 2018 at 03:46:27PM +0200, Michal Hocko wrote:
> On Thu 06-09-18 16:39:58, Mike Rapoport wrote:
> > On Thu, Sep 06, 2018 at 03:01:02PM +0200, Michal Hocko wrote:
> > > On Thu 06-09-18 15:43:21, Mike Rapoport wrote:
> > > > On Thu, Sep 06, 2018 at 09:28:00AM +0200, Michal Hocko wrote:
> > > > > On Wed 05-09-18 20:20:18, Mike Rapoport wrote:
> > > > > > On Wed, Sep 05, 2018 at 12:04:36PM -0500, Rob Herring wrote:
> > > > > > > On Wed, Sep 5, 2018 at 11:00 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> > > > > > > >
> > > > > > > > The conversion is done using
> > > > > > > >
> > > > > > > > sed -i 's@memblock_virt_alloc@memblock_alloc@g' \
> > > > > > > >         $(git grep -l memblock_virt_alloc)
> > > > > > > 
> > > > > > > What's the reason to do this? It seems like a lot of churn even if a
> > > > > > > mechanical change.
> > > > > > 
> > > > > > I felt that memblock_virt_alloc_ is too long for a prefix, e.g:
> > > > > > memblock_virt_alloc_node_nopanic, memblock_virt_alloc_low_nopanic.
> > > > > > 
> > > > > > And for consistency I've changed the memblock_virt_alloc as well.
> > > > > 
> > > > > I would keep the current API unless the name is terribly misleading or
> > > > > it can be improved a lot. Neither seems to be the case here. So I would
> > > > > rather stick with the status quo.
> > > > 
> > > > I'm ok with the memblock_virt_alloc by itself, but having 'virt' in
> > > > 'memblock_virt_alloc_try_nid_nopanic' and 'memblock_virt_alloc_low_nopanic'
> > > > reduces code readability in my opinion.
> > > 
> > > Well, is _nopanic really really useful in the name. Do we even need/want
> > > implicit panic/nopanic semantic? The code should rather check for the
> > > return value and decide depending on the code path. I suspect removing
> > > panic/nopanic would make the API slightly lighter.
> >  
> > I agree that panic/nopanic should be removed. But I prefer to start with
> > equivalent replacement to make it as automated as possible and update
> > memblock API when the dust settles a bit.
> 
> Yes, I agree with that approach. But that also doesn't justify the
> renaming

Well, the renaming is automated :)

Anyway, we can continue arguing about keeping or removing _virt regardless
of the bootmem -> memblock change. I'll redo the set with
memblock_virt_alloc and we can resume the argument later on :)

> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
