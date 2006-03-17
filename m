From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 17 Mar 2006 14:16:28 +0000
Subject: Re: [patch 2/2] mspec driver
Message-Id: <441AC4BC.4010904@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0k6auuy5n.fsf@jaguar.mkp.net>	<20060316163728.06f49c00.akpm@osdl.org>	<yq0bqw5utyc.fsf_-_@jaguar.mkp.net> <441ABB68.1020502@yahoo.com.au> <yq07j6tuq05.fsf@jaguar.mkp.net> <441AC300.8020003@yahoo.com.au> <441AC3A4.801@sgi.com>
In-Reply-To: <441AC3A4.801@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, hch@lst.de, cotte@de.ibm.com, Hugh Dickins <hugh@veritas.com>

Jes Sorensen wrote:
> Nick Piggin wrote:
> 
>>No problem, I think you should just stop using the VM_PFNMAP flag then.
>>[Linus should jump in here if I'm wrong ;)]
> 
> 
> I'd have to go back and find the discussion to verify, but if I
> remember correctly the conclusion was that I needed to use it in
> order to make sure that vm_normal_page() didn't start thinking it was
> in fact a real page, ie. VM_PFNMAP + never a COW mapping..
> 

Oh of course: the primary purpose for VM_PFNMAP is to signal a pfn
mapping, strangely enough. The COW facility is additional to that.
Sorry.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
