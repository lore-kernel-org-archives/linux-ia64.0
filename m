From: Jes Sorensen <jes@wildopensource.com>
Date: Fri, 21 Mar 2003 02:04:31 +0000
Subject: Re: [Linux-ia64] provide /proc/sal/itc_drift through AUX?
Message-Id: <marc-linux-ia64-105590723705282@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705273@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705273@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On 19 Mar 2003 21:06:20 -0500, Jes Sorensen <jes@wildopensource.com> said:
Jes> Let me get sure I understand you right here, you are suggesting I
Jes> add a new syscall to provide the info currently found in
Jes> /proc/sal/itc_drift? Right now it's just returning true/false
Jes> (1/0) as to whether the ITC drifts or not.

David> No, not at all.  I was simply suggesting to always use
David> gettimeofday().  The light-weight implementation of
David> gettimeofday() runs in ~130 cycles, which isn't much slower
David> than what you could do in user-level.

Ok, that makes it even simpler, I will do that then.

Cheers,
Jes

