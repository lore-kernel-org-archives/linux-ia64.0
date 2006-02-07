From: Prarit Bhargava <prarit@sgi.com>
Date: Tue, 07 Feb 2006 20:11:04 +0000
Subject: Re: [PATCH]: Remove kfree, and fix pcidev_info struct removals
Message-Id: <43E8FED8.7060508@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060206185244.12145.74416.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20060206185244.12145.74416.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> 
> Nothing in particular picky about this patch.  However, in
> sn_bus_free_sysdata(), the goto that branches outside the
> list_for_each loop looks like it needs a real clean up. How
> about using list_for_each_entry_safe?
> 

Kenneth,

I'm implementing this change in a separate patch (which will be out 
shortly).

P.
