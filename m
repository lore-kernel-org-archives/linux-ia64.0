From: Linus Torvalds <torvalds@osdl.org>
Date: Thu, 21 Apr 2005 21:08:00 +0000
Subject: Re: ia64 git pull
Message-Id: <Pine.LNX.4.58.0504211403080.2344@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504212042.j3LKgng04318@unix-os.sc.intel.com>
In-Reply-To: <200504212042.j3LKgng04318@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Thu, 21 Apr 2005 tony.luck@intel.com wrote:
> 
> First ia64 change is sitting in a GIT repository at:
> 
> 	http://www.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git
> 
> Please pull (and comment if anything is wrong, or could be improved ... e.g.
> what's the easiest way to name the repository for you to cut&paste?)

Looks good. Merged and pushed out.

I don't have a good naming convention yet, but since rsync ends up being 
the easiest way to fetch the data (and I like the irony of using a tool 
that Tridge helped write ;), the one I use for my merger is

	rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git

but we'll probably _eventually_ have a real git protocol for doing
transfers more efficiently by just having git-specific knowledge.

		Linus
