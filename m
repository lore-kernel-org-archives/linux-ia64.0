From: Kevin Buettner <kev@primenet.com>
Date: Wed, 22 Mar 2000 00:17:50 +0000
Subject: Re: [Linux-ia64] gdb support for IA32?
Message-Id: <marc-linux-ia64-105590678204993@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204990@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204990@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mar 21,  4:15pm, Don Dugger wrote:

> Funny you should ask.  I've just started to do this.  The ultimate
> goal would be to have a single `gdb' that operates on either an
> IA64 or IA32 process.  I think that would be a little tricky 

I agree that this is a desirable goal.  But to achieve it the IA-32
port will have to be fully mult-arch'd first.  (Since the IA-64 port
is a brand new port, we were able to properly multi-arch it from
the beginning.)

> so I'm trying to just take the current `gdb' sources, compile them
> on my IA64 machine and create a version of `gdb' that only works
> on IA32 processes running on IA64.  Assuming I don't run into any
> show stopper problems I should have it up and running within about
> a week.

Did you create a new ia64-linux-ia32-nat.c (or somesuch) file to fetch
the registers and such?

Another way to approach this would be to write a ptrace() interface
for IA-32 processes which provides the same functionality as the
existing linux/x86 kernel.  Then you could just take a gdb binary
built for linux/x86 and it'd work.  (Maybe.)

Other news from the gdb front...

  - I've committed the IA-64 specific sources in the gdb tree to the
    CVS repository at sourceware.cygnus.com.  We still need to get the
    binutils and opcodes sources committed, but Trillian members
    should be able to make use of this repository by fetching just the
    gdb tree from sourceware and using the binutils, opcodes, etc. 
    from the last release.  (Yes, this is less than optimal...)

  - I've gotten the code for calling inferior functions working.  In
    order to use it, you'll need to have my Mar 10 ptrace.c patches
    applied to your kernel.

  - There have been a number of other small changes and bug fixes
    which should improve the usability of the debugger.  E.g,
    when you do ``finish'', you'll now see the correct return value
    (so long as it's not an HFA).  Also, the ``return'' command now
    works.  Display of floating point values should now work much
    better provided you've fixed the __scalbn() compiler bug in
    your libc.  (But there are changes to some of the generic
    gdb code for floats as well...)

  - I am now able to run the gdb test suite.  I am presently whittling
    away at the number of failures.

I can put a newer gdb binary up on bunyip if desired...

Kevin

-- 
Kevin Buettner
kev@primenet.com, kevinb@redhat.com


