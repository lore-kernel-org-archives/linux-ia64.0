From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 15 Jan 2019 05:32:26 +0000
Subject: Re: [RFC PATCH] x86, numa: always initialize all possible nodes
Message-Id: <CAFgQCTsEtjKnCdUb=0d9aTNL94L1=XQGDtot=2MqmqQ-fqmr1g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190114082416.30939-1-mhocko@kernel.org> <87pnszzg9s.fsf@concordia.ellerman.id.au>
In-Reply-To: <87pnszzg9s.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

[...]
> >
> > I would appreciate a help with those architectures because I couldn't
> > really grasp how the memoryless nodes are really initialized there. E.g.
> > ppc only seem to call setup_node_data for online nodes but I couldn't
> > find any special treatment for nodes without any memory.
>
> We have a somewhat dubious hack in our hotplug code, see:
>
> e67e02a544e9 ("powerpc/pseries: Fix cpu hotplug crash with memoryless nodes")
>
> Which basically onlines the node when we hotplug a CPU into it.
>
This bug should be related with the present state of numa node during
boot time. On PowerNV and PSeries, the boot code seems not to bring up
all nodes if memoryless. Then it can not avoid this bug.

Thanks,
Pingfan
