From: "H . J . Lu" <hjl@valinux.com>
Date: Mon, 13 Nov 2000 21:17:04 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels test1 0 and upper?
Message-Id: <marc-linux-ia64-105590678205697@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 13, 2000 at 01:14:47PM -0800, Jim Wilson wrote:
> >FYI, last time when I checked it, this bug
> >http://gcc.gnu.org/ml/gcc-bugs/2000-08/msg00526.html
> >still is in CVS. BTW, there are some analysis and a kludge at
> >http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id836
> 
> But that isn't an ia64 compiler bug, so it isn't really my problem.  

I doubt it should show up in ia64 unless we are talking 128bit type.

> And since it only shows up in an unusual case, presumably from using the
> --enable-shared configure option which few people use, and since there is
> an easy workaround, I see no reason why I need to spend time trying to fix it.
> 

That is one reason I never really pushed for it. I mentioned it just
in case someone wants to take a look at it :-).

-- 
H.J. Lu (hjl@valinux.com)

