From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 05 Aug 2004 21:50:58 +0000
Subject: IA64 bitkeeper trees
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01CB29F1@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>, Pat Gefre <pfg@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Grant Grundler wrote:
>On Wed, Aug 04, 2004 at 03:14:08PM -0500, Pat Gefre wrote:
>> We are posting this code for review before submitting for 
>>inclusion in
>> the 2.5 tree.
>
>I'm sure you really meant 2.6.
>
>> The patch set is at: ftp://oss.sgi.com/projects/sn2/sn2-update/
>> 
>> It is based off the http://lia64.bkbits.net/to-linus-2.5 tree
>
>I was previously told to not use that tree.
>It's only for linus to pull a subset of patches from.
>
>Tony, is "http://lia64.bkbits.net:8080/linux-ia64-2.56" the right
>tree to use?

Historically Bjorn and David each maintained two bitkeeper trees,
one of them "to-marcelo-2.4" and "to-linux-2.5" is/was used simply
as a repository for pushing ia64 specific changesets to be pulled
by the upstream maintainer.  The other "linux-ia64-2.4" for Bjorn
and "linux-ia64-2.5" for David is/was used to keep track of stuff
that isn't ready for the base.

During 2.5 all of the code required for ia64 to run was accepted
into Linus's tree ... so the delta between David's tree and Linus's
dropped at one point to zero.  Linus's tree has remained usable
without an ia64 patch since then.

I've set up two bitkeeper trees too:
	http://lia64.bkbits.net/to-base-2.6
is my holding area for patches that I want Linus to pull.

	http://lia64.bkbits.net/linux-ia64-2.6
will be a place for me to stash changesets that I'm not ready
to push (or for any non-ia64 specific changes that I want to
play with).  At the moment there is nothing in this tree that
isn't also queued in the to-base-2.6 tree.

Summary: For 99% of uses, you can clone a tree from Linus and
use it on ia64.  If you are sending a sequence of related patches
and know that I've taken some of them, then either of my trees
should work for you.

-Tony

