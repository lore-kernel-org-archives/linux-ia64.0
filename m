From: Ulrich Drepper <drepper@redhat.com>
Date: Fri, 04 Jun 2004 06:12:49 +0000
Subject: Re: GLIBC IA64 HP_TIMING fixes for SMP systems with unsynchronized
Message-Id: <40C012E1.9030302@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406031313420.32412@server.home>
In-Reply-To: <Pine.LNX.4.58.0406031313420.32412@server.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

> Does anyone else find it annoying that gettimeofday() only provides
> micro-second resolution?  We can do syscalls significantly faster than
> that (especially with a light-weight syscall handler).  Time for a
> kernel extension?

What do you think clock_gettime(CLOCK_REALTIME) is for?

-- 
➧ Ulrich Drepper ➧ Red Hat, Inc. ➧ 444 Castro St ➧ Mountain View, CA ❖
