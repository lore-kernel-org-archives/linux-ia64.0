From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Wed, 23 Nov 2005 16:30:59 +0000
Subject: Re: [Xen-devel] __ia64__ ifdef in xmalloc.c: "Fix ar.unat handling forfast paths"
Message-Id: <ed5aea430511230830v68b02db6g2bd61996fe243a8a@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <571ACEFD467F7749BC50E0A98C17CDD802C069E3@pdsmsx403>
In-Reply-To: <571ACEFD467F7749BC50E0A98C17CDD802C069E3@pdsmsx403>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Tian, Kevin" <kevin.tian@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Rusty Russell <rusty@rustcorp.com.au>, Xen Mailing List <xen-devel@lists.xensource.com>, Tony Breeds <tony@bakeyournoodle.com>, djm@kirby.fc.hp.com, linux-ia64@vger.kernel.org

On 11/22/05, Tian, Kevin <kevin.tian@intel.com> wrote:
> Now I think even '16' can't cover all cases. It's possible for a user defined structure with .align directive to force by '32' or larger, and then allocator happens to have similar check upon SMP_CACHE_BYTES like case in this thread. Because both structure definition and allocator may have no idea about IA64 trick of saving space for UP. Max alignment of any C style only solves the natural alignment case, but not above forced one. We can just give its real assumption to SMP_CACHE_BYTES - cache line size. ;-)

Not likely to be a problem.  Memory allocators generally guarantee
only 16-byte alignment (as per ia64 software conventions).

  --david
--
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
