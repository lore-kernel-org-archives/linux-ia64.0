From: Keith Owens <kaos@sgi.com>
Date: Thu, 27 Mar 2003 23:15:02 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-ia64-021210 new spinlock code
Message-Id: <marc-linux-ia64-105590723705341@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805543@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805543@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 27 Mar 2003 12:29:04 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Sat, 15 Mar 2003 21:31:53 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> On Fri, 14 Mar 2003 22:46:28 -0800, 
>  Keith> David Mosberger <davidm@napali.hpl.hp.com> wrote:
>  >> I thought about it some more and recalled why I was so uneasy about
>  >> claiming ar.pfs is 0: the problem is that this informs that the
>  >> _previous_ register frame was empty, not the current one.  So the
>  >> unwind info technically is still wrong.  I think you realize that, and
>  >> the kernel unwinder won't complain, since it's not paranoid about
>  >> validating accesses to stacked registers.  But still, the unwind info
>  >> is wrong and I'm not terribly comfortable with that.
>
>  Keith> I agree, but the end result is benign.
>
>I disagree.  A bug is a bug.  Relying on implementation-specific
>behavior of one particular unwinder doesn't change that.

The code does not rely on any implementation specific behaviour.
Stating that ar.pfs is zero is well defined, it means that the caller
(rp in r28) of this code has no frame.  Therefore the current cfm is
attributed to the contention code.  No matter how you read the unwind
spec, that construct is well defined and assigns the correct number of
registers to the _sum_ of the main line code and the contention path.
Therefore unwind through the mainline code will work correctly.

>  Keith> How about putting the new spinlock code in now so I can
>  Keith> continue with adding kdb support for debugging hung
>  Keith> spinlocks?  Even with the swapped arg list, any debug data on
>  Keith> hung spinlocks is better than none at all.  I will think some
>  Keith> more about the unwind descriptors to see if there is any way
>  Keith> of avoiding the misattribution of the register usage, but the
>  Keith> worst case is that we live with the swapped argument list.
>
>My experience tells me that if I put in the code now, nobody will work
>on a corrected version.
>
>I think it makes sense to start a discussion of extending the unwind
>spec to make it easier to accommodate what we're trying to do here.  A
>similar facility already exists in libunwind for dynamic unwind info
>(since runtime function cloning naturally leads to the same issue).

They are superficially similar but the unwind implementation would be
quite different.  Function cloning results in a call structure which
modifies ar.pfs plus a copy of the complete prologue and body of the
function.  That cannot be handled by a single "my state is the same as
that one over there" pointer.  It needs an unwind table entry for the
length and address of the new function that points to the info block
for the function it was cloned from.  Adding an unwind table entry does
not require any change to the unwind spec, it just needs the
implementation to support multiple unwind tables, which the spec
already allows.

Out of line code entered via a direct branch needs an unwind construct
that says ar.pfs is not changed by unwinding through the return
pointer.  IOW, this is _not_ a call structure, even through it has a
return pointer.  This requires a new unwind descriptor type, all the
existing unwind descriptors implicitly assume a call structure.  The
ideal would be a copy_state descriptor that took a register name
instead of a numbered label, i.e. like B4 but taking treg instead of
label.

It is the difference between unwind data that replicates an entire
function (and requires all the unwind info for that function) and
unwind data for a single return point.

>Can you start this discussion?

I can start it, but it will take months to get agreement on the change
to the unwind spec, followed by more time for the ia64 assemblers to be
upgraded to handle the new unwind descriptor and more time for users to
upgrade to the new binutils before the kernel can use any new
construct.  I want to get debugging working for hung ia64 spinlocks
this month, not in a year's time.

BTW, the new spinlock code with the out of line contention code is
faster.

David, you added the NEW_LOCK code even though it never worked and
could never work.  But when I supply code that works, is faster, allows
for better debugging and performance monitoring you quibble about one
construct to get the unwind data right.  I do not understand your
priorities here.


