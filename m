From: Ulrich Drepper <drepper@redhat.com>
Date: Tue, 18 Sep 2001 09:12:59 +0000
Subject: Re: [Linux-ia64] PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805205@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805193@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805193@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen <jes@sunsite.dk> writes:

> It would have been extremely nice if the people who decided to write
> this standard had started out by asking the people who did the
> implementation work how the architecture really works and what
> experience has been gained in these areas already.

Well, this is not fair.  I have been there when the spec was written.
At that time it was not yet decided how Linux would handle this.  It
was strongly felt by all the Unix people that the way it is specified
things should be implemented.  When the decisions for Linux were made
and they conflicted nothing happened to rectify the problem.

It's just that we have more liberties and can do things right while
the Unix vendors feel they must pay attention to l^Husers using IA-32
binaries.  It's there problem if they want to make the life of
programmers and sysadmins harder.

-- 
---------------.                          ,-.   1325 Chesapeake Terrace
Ulrich Drepper  \    ,-------------------'   \  Sunnyvale, CA 94089 USA
Red Hat          `--' drepper at redhat.com   `------------------------

