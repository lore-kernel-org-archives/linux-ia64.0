From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 15 Dec 2017 02:49:26 +0000
Subject: Re: Adding init_task consolidation patches to linux-next
Message-Id: <20171215134926.1a836c99@canb.auug.org.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <151274828194.9961.4230316917108602662.stgit@warthog.procyon.org.uk>
        <10228.1512748600@warthog.procyon.org.uk>
In-Reply-To: <10228.1512748600@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Howells <dhowells@redhat.com>
Cc: linux-arch@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-next@vger.kernel.org

Hi David,

On Fri, 08 Dec 2017 15:56:40 +0000 David Howells <dhowells@redhat.com> wrote:
>
> Can you add the following to linux-next please?
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=init_task

AKA git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git#init_task

Added from today.

Thanks for adding your subsystem tree as a participant of linux-next.  As
you may know, this is not a judgement of your code.  The purpose of
linux-next is for integration testing and to lower the impact of
conflicts between subsystems in the next merge window. 

You will need to ensure that the patches/commits in your tree/series have
been:
     * submitted under GPL v2 (or later) and include the Contributor's
        Signed-off-by,
     * posted to the relevant mailing list,
     * reviewed by you (or another maintainer of your subsystem tree),
     * successfully unit tested, and 
     * destined for the current or next Linux merge window.

Basically, this should be just what you would send to Linus (or ask him
to fetch).  It is allowed to be rebased if you deem it necessary.

-- 
Cheers,
Stephen Rothwell 
sfr@canb.auug.org.au
