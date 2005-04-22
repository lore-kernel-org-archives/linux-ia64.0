From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Fri, 22 Apr 2005 01:48:35 +0000
Subject: Re: ia64 git pull
Message-Id: <17000.22515.170455.192374@sodium.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504212042.j3LKgng04318@unix-os.sc.intel.com>
	<Pine.LNX.4.58.0504211403080.2344@ppc970.osdl.org>
	<200504212155.j3LLtho04949@unix-os.sc.intel.com>
	<200504212301.j3LN1Do05507@unix-os.sc.intel.com>
	<20050422012546.GD1474@pasky.ji.cz>
In-Reply-To: <20050422012546.GD1474@pasky.ji.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Baudis <pasky@ucw.cz>
Cc: tony.luck@intel.com, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> Petr Baudis <pasky@ucw.cz> writes:

> I've just added to git-pasky a possibility to refer to branches
> inside of repositories by a fragment identifier:

> rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git#testing

> will refer to your testing branch in that repository.

Can we use something other than #? we'll have to scape it all the time
in the shell (or at least also allow some other char, something
without special meta-character meaning in the shell, like %).

-- 

Inaky

