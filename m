From: Jes Sorensen <jes@wildopensource.com>
Date: Tue, 22 Feb 2005 22:30:41 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <yq04qg4i5wu.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net>
	<1109109833.6024.109.camel@laptopd505.fenrus.org>
In-Reply-To: <1109109833.6024.109.camel@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arjan van de Ven <arjan@infradead.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> "Arjan" = Arjan van de Ven <arjan@infradead.org> writes:

Arjan> On Tue, 2005-02-22 at 04:52 -0500, Jes Sorensen wrote:
>> Hi,
>> 
>> This patch introduces ia64 specific read/write handlers for
>> /dev/mem access which is needed to avoid uncached pages to be
>> accessed through the cached kernel window which can lead to random
>> corruption. It also introduces a new page-flag PG_uncached which
>> will be used to mark the uncached pages. I assume this may be
>> useful to other architectures as well where the CPU may use
>> speculative reads which conflict with uncached access. In addition
>> I moved do_write_mem to be under ARCH_HAS_DEV_MEM as it's only ever
>> used if that is defined.
>> 
>> The patch is needed for the new ia64 special memory driver (mspec -
>> former fetchop).

Arjan> is there ANY valid reason to allow access to cached uses at
Arjan> all?  (eg kernel ram)

Arjan> why not just disable any such ram access entirely...

You mean uncached?

For userspace it's used by some of the MPI type apps in userland.
Presumably there's cases where it gives better performance. For the
SN2 hardware there's also a special mode known as fetchop mode which
requires uncached memory, it's used quite heavily by the same types of
apps.

The problem is if you then have apps such as lcrash which may read
through all kernel memory. If a page is mapped uncached to userland
you can hit the memory corruption case if you access the same page
cached from within a kernel cached mapping. I suspect the suspend code
could hit similar problems, but I don't know that code well enough to
say if it's the case or not.

Cheers,
Jes
