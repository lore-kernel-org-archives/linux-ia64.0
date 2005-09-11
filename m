From: Linus Torvalds <torvalds@osdl.org>
Date: Sun, 11 Sep 2005 22:56:28 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <Pine.LNX.4.58.0509111554310.3242@g5.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Sun, 11 Sep 2005, Luck, Tony wrote:
> 
> 	rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release
>
>  include/linux/sched.h                 |    2 
>  kernel/sched.c                        |   26 

I took a look, and quite frankly, I'm not at all happy about this.

What's going on? Why would machine check interrupts muck with these 
things? Pls explain.. This is a total violation of all layering, and 
anybody who uses these things is just going to cause strange oopses etc 
crap.

Wazzup?

		Linus
