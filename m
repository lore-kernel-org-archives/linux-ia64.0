From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Sat, 18 Oct 2003 02:01:52 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106644274924705@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 17, 2003 at 06:48:33PM -0700, David Mosberger wrote:
> >>>>> On Fri, 17 Oct 2003 17:49:55 -0700, Andrew Morton <akpm@osdl.org> said:
> 
>   Andrew> We _want_ to be able to read mmio ranges via /dev/mem, don't
>   Andrew> we?  I guess it has never come up because everyone uses
>   Andrew> kmem.
> 
> I just don't see how making a "dd if=/dev/mem" safe and allowing
> access to arbitrary physical memory can go to together.  Given that
> /dev/mem _is_ being used for accessing mmio space, is it really worth
> bothering trying to make such a "dd" safe?

Usually people who want to access MMIO devices would use mmap rather
than read/write.

But I do agree that the current semantics are not unreasonable and the
user should think about what they're doing before accessing random parts
of /dev/mem.

Matt

