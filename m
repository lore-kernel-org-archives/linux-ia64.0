From: Ulrich Drepper <drepper@redhat.com>
Date: Thu, 15 Jun 2000 16:49:14 +0000
Subject: Re: [Linux-ia64] signal interface: SIGINFO and sa_sigaction
Message-Id: <marc-linux-ia64-105590678205144@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205139@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205139@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

> Yes, I see what you mean.  It looks like the glibc header file doesn't
> define sa_sigaction as a (properly typed) synonym of sa_handler.  Jes,
> can you fix this?

I changed this already in my version of the tree before checking it in.

-- 
---------------.      drepper at gnu.org  ,-.   1325 Chesapeake Terrace
Ulrich Drepper  \    ,-------------------'   \  Sunnyvale, CA 94089 USA
Red Hat          `--' drepper at redhat.com   `------------------------


