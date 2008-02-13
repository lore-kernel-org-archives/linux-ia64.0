From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 13 Feb 2008 00:34:35 +0000
Subject: RE: [PATCH] Reduce per_cpu allocations to the minimum needed for boot -V5.
Message-Id: <1FE6DD409037234FAB833C420AA843EC907244@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080211175918.GO3875@sgi.com>
In-Reply-To: <20080211175918.GO3875@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Please don't apply this yet.  I just noticed the CONFIG_FLATMEM configs
>> did not work.  I will look at this more this evening.
>
> That reminds me: I have a patch to remove all other memory models except 
> for SPARSE_VMEMMAP for ia64 somewhere.... If we would merge that then 
> maintaining ia64 may become simpler.

Sounds wonderful ... I'm very much in favour of patches that reduce
the twisty maze of different CONFIG options.

-Tony

