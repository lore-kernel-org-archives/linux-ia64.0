From: Ben Woodard <woodard@redhat.com>
Date: Thu, 04 Dec 2003 01:38:19 +0000
Subject: Re: [patch] 2.6.0-test9 pal/sal/salinfo/mca
Message-Id: <marc-linux-ia64-107050247125541@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106978478405713@msgid-missing>
In-Reply-To: <marc-linux-ia64-106978478405713@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2003-11-25 at 00:37, Keith Owens wrote:
> Forward port the recent changes to pal.h, sal.h, mca.h, salinfo.c and
> mca.c from 2.4.23-rc2 to 2.6.0-test9.
> 
> This converts 2.6 to use salinfo instead of printing CMC/CPE/MCA/INIT
> records in the kernel.  It makes the two kernel versions as close
> together as possible.

I'd like to inquire a bit more into the state of MCA in 2.4 and 2.6. We
are assembling a 1000 node ia64 cluster out of intel Tiger 4 servers and
we want to make sure that MCA works well enough that we can at least get
a good count of the ECC SBE's and panic if we get a MBE. 

We are currently basing our kernel off of the Red Hat Enterprise Linux 3
kernel and we discovered that the implementation of MCA included with it
does not work for us. The most obvious problem is that it never calls
ia64_sal_clear_state_info after fetching a SAL record. Thus the CPE
reasserts itself and the machine effectively locks up infinitely
printing out the same CPE to the console.

So what we are trying to do is improve the state of the MCA handling in
our kernel. I managed a backport of the MCA code from 2.6.0-test9 to 2.4
and it works much better. However, there are a couple of problems with
it that could probably be sorted out by someone who understands the code
better. Keith your message sort of hints that the possibility that the
2.4 kernel's MCA code is further advanced than the 2.6 code. This led us
initially to believe that we could backport the 2.4.23 kernel's MCA code
and have it work. However, taking a look at the 2.4.23 kernel from
kernel.org, it is quickly evident that it doesn't make the needed call
to sal_clear_state_info.

So my question is: should we continue forward with our backport of the
2.6 MCA code or is the 2.4 code actually functional enough to support
our needs and we are missing something in our quick inspection of the
code.

Also if the 2.6 backport is the way to go, would other people be
interested in having the 2.6 MCA code backport made available? Once we
get it working satisfactorily here, I'm going to push for it to be
integrated into the Red Hat kernel. Is this something that, would be
worthwhile to push upstream?

-ben



