From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 28 Oct 2002 19:03:42 +0000
Subject: [Linux-ia64] RE: Fixing /proc/kcore
Message-Id: <marc-linux-ia64-105590709805279@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805249@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805249@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andi Kleen wrote:
> On Fri, Oct 25, 2002 at 02:14:44PM -0700, Luck, Tony wrote:
> > Putting everything into the vmlist looks to be a good idea.  Perhaps
> > there should be an entry for the "direct addresses" too?
> 
> Yes that would make sense.
> 
> > 
> > So what does:
> > 
> > 	# objdump -p /proc/kcore
> > 
> > look like for you?
> 
> Very messy because of the negative addresses and still some sign problems
> in binutils :-)

Oops, I didn't mean to take this discussion off the mailing list.

What about a combined approach ... architecture dependent code
should add all the interesting stuff to the vmlist, so kcore just
needs to walk the list to cover everything.  We could also keep the
KCORE_BASE concept from my patch, but turn it into a variable that
the architecture dependent code can set to some suitable offset to
keep all the offsets in /proc/kcore positive.  This will avoid
having to fixup binutils (at least until someone comes up with an
architecture where kernel space scatters across a wide enough range
that we can't keep the offsets positive).

-Tony

