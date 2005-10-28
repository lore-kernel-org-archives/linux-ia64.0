From: Linus Torvalds <torvalds@osdl.org>
Date: Fri, 28 Oct 2005 23:57:52 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <Pine.LNX.4.64.0510281656060.3348@g5.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Fri, 28 Oct 2005, Luck, Tony wrote:
> 
> please pull from:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

Hmm. I get:

	* committish: 4bcde03d41d2264edb4ea3c47cb27da1e2609e48
	  branch 'release' of git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6
	Already up-to-date.

if you _just_ pushed the thing out, then it may not have mirrored (I'm 
really happy that there's git.kernel.org, but "master" still ends up 
having the advantage of being immediate).

		Linus
