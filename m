From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 16 Aug 2003 00:43:44 +0000
Subject: Re: [PATCH] Fix prologue directives for sys_clone() and sys_clone2()]
Message-Id: <marc-linux-ia64-106099463822652@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106099247521466@msgid-missing>
In-Reply-To: <marc-linux-ia64-106099247521466@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 15 Aug 2003 17:07:41 -0700, John Byrne <john.l.byrne@hp.com> said:

  John> To my limited understanding, the GRSAVE portions of the .prologue
  John> directives for sys_clone() and sys_clone2() are incorrect. This patch, 
  John> against 2.6.0-test3, fixes them.

Thanks, I applied the patch.

  John> I also wonder whether the the continued usage of the 2
  John> argument form of clone() in kernel_thread() should be
  John> considered "bad form". Admittedly, the other arguments are
  John> don't-care as long as the various CLONE_ flags (which
  John> kernel_thread() does not mask off) are not set , but it just
  John> feels wrong. I guess I wouldn't be a programmer if I didn't
  John> like to pick nits.

clone() is a strict subset of clone2(), so some day we may want to
remove the former.

	--david
