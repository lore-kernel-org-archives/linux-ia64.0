From: "H . J . Lu" <hjl@valinux.com>
Date: Mon, 13 Nov 2000 20:52:03 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels test1 0 and upper?
Message-Id: <marc-linux-ia64-105590678205694@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 13, 2000 at 12:34:53PM -0800, Jim Wilson wrote:
> >Does this compiler support cross-compilation?
> 
> Yes.  It has probably been a few months since I last built a cross-compiler
> myself, but other people have been building them successfully.  There was a
> comment from H.J. claiming that the Red Hat 7.0 ia32 OS release can't build a
> cross-compiler because of bugs in the compiler shipped with that release.
> Otherwise, I don't know of any specific problems.
> 

FYI, last time when I checked it, this bug

http://gcc.gnu.org/ml/gcc-bugs/2000-08/msg00526.html

still is in CVS. BTW, there are some analysis and a kludge at

http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id836


-- 
H.J. Lu (hjl@valinux.com)

