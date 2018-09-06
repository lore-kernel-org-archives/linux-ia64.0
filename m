From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Thu, 06 Sep 2018 12:43:21 +0000
Subject: Re: [RFC PATCH 07/29] memblock: remove _virt from APIs returning virtual address
Message-Id: <20180906124321.GD27492@rapoport-lnx>
List-Id: <linux-ia64.vger.kernel.org>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-8-git-send-email-rppt@linux.vnet.ibm.com>
 <CABGGiswdb1x-=vqrgxZ9i2dnLdsgtXq4+5H9Y1JRd90YVMW69A@mail.gmail.com>
 <20180905172017.GA2203@rapoport-lnx>
 <20180906072800.GN14951@dhcp22.suse.cz>
In-Reply-To: <20180906072800.GN14951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: Rob Herring <robh@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, mingo@redhat.com, Michael Ellerman <mpe@ellerman.id.au>, paul.burton@mips.com, Thomas Gleixner <tglx@linutronix.de>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Sep 06, 2018 at 09:28:00AM +0200, Michal Hocko wrote:
> On Wed 05-09-18 20:20:18, Mike Rapoport wrote:
> > On Wed, Sep 05, 2018 at 12:04:36PM -0500, Rob Herring wrote:
> > > On Wed, Sep 5, 2018 at 11:00 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> > > >
> > > > The conversion is done using
> > > >
> > > > sed -i 's@memblock_virt_alloc@memblock_alloc@g' \
> > > >         $(git grep -l memblock_virt_alloc)
> > > 
> > > What's the reason to do this? It seems like a lot of churn even if a
> > > mechanical change.
> > 
> > I felt that memblock_virt_alloc_ is too long for a prefix, e.g:
> > memblock_virt_alloc_node_nopanic, memblock_virt_alloc_low_nopanic.
> > 
> > And for consistency I've changed the memblock_virt_alloc as well.
> 
> I would keep the current API unless the name is terribly misleading or
> it can be improved a lot. Neither seems to be the case here. So I would
> rather stick with the status quo.

I'm ok with the memblock_virt_alloc by itself, but having 'virt' in
'memblock_virt_alloc_try_nid_nopanic' and 'memblock_virt_alloc_low_nopanic'
reduces code readability in my opinion.

Besides, from what I've seen, many users of memblock_phys_alloc can be
converted to the virtual variant and then we can just have memblock_alloc
everywhere in the end.

Currently there are ~70 users of memblock_virt_alloc*, but with the
bootmem -> memblock conversion we'll be adding ~140 more.

> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
