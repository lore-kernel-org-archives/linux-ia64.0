From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 17 Mar 2006 14:09:04 +0000
Subject: Re: [patch 2/2] mspec driver
Message-Id: <441AC300.8020003@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0k6auuy5n.fsf@jaguar.mkp.net>	<20060316163728.06f49c00.akpm@osdl.org>	<yq0bqw5utyc.fsf_-_@jaguar.mkp.net> <441ABB68.1020502@yahoo.com.au> <yq07j6tuq05.fsf@jaguar.mkp.net>
In-Reply-To: <yq07j6tuq05.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, hch@lst.de, cotte@de.ibm.com, Hugh Dickins <hugh@veritas.com>

Jes Sorensen wrote:
>>>>>>"Nick" = Nick Piggin <nickpiggin@yahoo.com.au> writes:
> 
> 
> Nick> Jes Sorensen wrote:
> 
>>>+ vma->vm_flags |= (VM_IO | VM_LOCKED | VM_RESERVED | VM_PFNMAP);
> 
> 
> Nick> VM_PFNMAP actually has a fairly specific meaning [unlike the
> Nick> rest of them :)] so you should be careful with it. Actually if
> Nick> you set vm_pgoff in the right way, then that should enable you
> Nick> to do COWs on these areas if that is what you want.
> 
> Yup, I went through that when I started using it. I think you guided
> me through it :-)
> 
> We don't want COW here as the access is backed by special behavior in
> the memory controller. We only allow shared mappings for that reason.
>

No problem, I think you should just stop using the VM_PFNMAP flag then.
[Linus should jump in here if I'm wrong ;)]

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
