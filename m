From: Petr Baudis <pasky@ucw.cz>
Date: Fri, 22 Apr 2005 00:20:43 +0000
Subject: Re: ia64 git pull
Message-Id: <20050422002043.GC1474@pasky.ji.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504212042.j3LKgng04318@unix-os.sc.intel.com> <Pine.LNX.4.58.0504211403080.2344@ppc970.osdl.org> <200504212155.j3LLtho04949@unix-os.sc.intel.com> <200504212155.j3LLtho04949@unix-os.sc.intel.com> <200504212301.j3LN1Do05507@unix-os.sc.intel.com> <Pine.LNX.4.58.0504211608300.2344@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0504211608300.2344@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Dear diary, on Fri, Apr 22, 2005 at 01:19:47AM CEST, I got a letter
where Linus Torvalds <torvalds@osdl.org> told me that...
> So in the long run this issue goes away - we'll just have synchronization 
> tools that won't get any unnecessary pollution. But in the short run I 
> actually check my git archive religiously for being clean, and I do
> 
> 	fsck-cache --unreachable $(cat .git/HEAD)
> 
> quite often - not because git has been flaky, but simply beause I'm anal. 
> And getting objects from other branches would mess with that..

(Note that when using git-pasky, you need to do

	fsck-cache --unreachable $(cat .git/heads/*)

instead.)

-- 
				Petr "Pasky" Baudis
Stuff: http://pasky.or.cz/
C++: an octopus made by nailing extra legs onto a dog. -- Steve Taylor
