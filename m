From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 13 Nov 2000 21:14:47 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels test1 0 and upper?
Message-Id: <marc-linux-ia64-105590678205696@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>FYI, last time when I checked it, this bug
>http://gcc.gnu.org/ml/gcc-bugs/2000-08/msg00526.html
>still is in CVS. BTW, there are some analysis and a kludge at
>http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id836

But that isn't an ia64 compiler bug, so it isn't really my problem.  
And since it only shows up in an unusual case, presumably from using the
--enable-shared configure option which few people use, and since there is
an easy workaround, I see no reason why I need to spend time trying to fix it.

Jim

