From: Andi Kleen <ak@suse.de>
Date: Mon, 28 Oct 2002 19:10:11 +0000
Subject: [Linux-ia64] Re: Fixing /proc/kcore
Message-Id: <marc-linux-ia64-105590709805280@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805249@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805249@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 28, 2002 at 11:03:42AM -0800, Luck, Tony wrote:
> What about a combined approach ... architecture dependent code
> should add all the interesting stuff to the vmlist, so kcore just
> needs to walk the list to cover everything.  We could also keep the

Works for me. You just have to make sure to keep vmlist ordered
and make sure all users of vmlist check for their correct address
range (vmalloc.c does, but some arch specific code may not)

> KCORE_BASE concept from my patch, but turn it into a variable that
> the architecture dependent code can set to some suitable offset to
> keep all the offsets in /proc/kcore positive.  This will avoid
> having to fixup binutils (at least until someone comes up with an
> architecture where kernel space scatters across a wide enough range
> that we can't keep the offsets positive).

x86-64 is such an architecture, so binutils will need to be fixed anyways.

-andi

