From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 11 Dec 2007 03:11:25 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <alpine.LFD.0.9999.0712101904030.28293@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Mon, 10 Dec 2007, Luck, Tony wrote:
> 
> Should I update my script that makes the "Please pull" message.

It should be added automatically to the diffstat if you create the 
diffstat with

	git diff -C --stat --summary linus...release

(that triple dot creates the diff from the last common point - the 
so-called merge-base - and it generally does the right thing unless you've 
merged things from me)

> Right now it just uses "git whatchanged release ^linus | git-shortlog"
> which doesn't mention any mode changes ... thus your understandable
> confusion about whether I had meant to make this change.
> 
> What git command would neatly summarize any mode changes?  Or would
> I have to roll my own from the whatchanged output?

I thought you already generated the diffstat with "git diff --stat", and 
if so, just adding "--summary" should do it.

That does a list of what files changed modes, and what files were created, 
deleted, moved or copied. So for the commit in question, we 
get

	[torvalds@woody linux]$ git show -C --stat --summary ff08e657f3e7224d090dd816e00cea2c110575c4

	commit ff08e657f3e7224d090dd816e00cea2c110575c4
	Author: Andrew Morton <akpm@linux-foundation.org>
	Date:   Fri Dec 7 14:42:08 2007 -0800
	
	    [IA64] don't assume that unwcheck.py is executable
	
	    Don't assume that this file has execute permissions.  For example, patch(1)
	    loses that information.
	
	    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
	    Signed-off-by: Tony Luck <tony.luck@intel.com>
	
	 arch/ia64/Makefile            |    2 +-
	 1 files changed, 1 insertions(+), 1 deletions(-)
	 mode change 100755 => 100644 arch/ia64/scripts/unwcheck.py

but it works with the other diff generation tools too (ie doing 
something like "git log -C --stat --summary" will do the obvious thing)

		Linus
