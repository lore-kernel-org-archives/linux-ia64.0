From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 11 Feb 2005 18:51:12 +0000
Subject: RE: [PATCH] Convert pgtable cache to slab
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02E63FFB@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Do you have some before/after numbers from lmbench fork overhead
>> (I wouldn't expect much impact from this, but it would be nice to
>> make sure).
>
>I am running lmbench even as we speak.  Is there a way to run lmbench
>and only get the fork overhead information?

You can run the "lat_proc" binary with the "fork" argument.

>I started with this patch because it goes part of the way to where I
>need to be.  I am trying to get 4 level page table directories working
>efficiently on SGI boxes.  I see this as three problems.

Do you mean full four-level page tables, or just fixing the quirks
in the current implementation that has an empty PUD level (and seems
to have caused a slight drop in performance for reasons that are not
yet completely understood)?

>Right now, neither the quicklists nor slabs are node local.  I think
>that is a larger issue.  I will start a seperate discussion about node
>locality soon.

Making the slab node aware is probably the right thing to do, but
making quicklists node aware is less invasive.

-Tony
