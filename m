From: Petr Baudis <pasky@ucw.cz>
Date: Fri, 22 Apr 2005 01:25:46 +0000
Subject: Re: ia64 git pull
Message-Id: <20050422012546.GD1474@pasky.ji.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504212042.j3LKgng04318@unix-os.sc.intel.com> <Pine.LNX.4.58.0504211403080.2344@ppc970.osdl.org> <200504212155.j3LLtho04949@unix-os.sc.intel.com> <200504212155.j3LLtho04949@unix-os.sc.intel.com> <200504212301.j3LN1Do05507@unix-os.sc.intel.com>
In-Reply-To: <200504212301.j3LN1Do05507@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Dear diary, on Fri, Apr 22, 2005 at 01:01:13AM CEST, I got a letter
where tony.luck@intel.com told me that...
> But now I need a way to indicate to consumers of the public shared object
> data base which HEAD to use.
> 
> Perhaps I should just say "merge 821376bf15e692941f9235f13a14987009fd0b10
> from rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git"?

I've just added to git-pasky a possibility to refer to branches inside
of repositories by a fragment identifier:

rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git#testing

will refer to your testing branch in that repository.

HTH,

-- 
				Petr "Pasky" Baudis
Stuff: http://pasky.or.cz/
C++: an octopus made by nailing extra legs onto a dog. -- Steve Taylor
