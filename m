From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 17 Mar 2006 13:36:40 +0000
Subject: Re: [patch 2/2] mspec driver
Message-Id: <441ABB68.1020502@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0k6auuy5n.fsf@jaguar.mkp.net>	<20060316163728.06f49c00.akpm@osdl.org> <yq0bqw5utyc.fsf_-_@jaguar.mkp.net>
In-Reply-To: <yq0bqw5utyc.fsf_-_@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, hch@lst.de, cotte@de.ibm.com, Hugh Dickins <hugh@veritas.com>

Jes Sorensen wrote:

> +static int
> +mspec_mmap(struct file *file, struct vm_area_struct *vma, int type)

...

> +	vma->vm_flags |= (VM_IO | VM_LOCKED | VM_RESERVED | VM_PFNMAP);

VM_PFNMAP actually has a fairly specific meaning [unlike the rest of
them :)] so you should be careful with it. Actually if you set vm_pgoff
in the right way, then that should enable you to do COWs on these areas
if that is what you want.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
