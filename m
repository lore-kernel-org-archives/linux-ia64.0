From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 Mar 2003 19:57:01 +0000
Subject: Re: [Linux-ia64] provide /proc/sal/itc_drift through AUX?
Message-Id: <marc-linux-ia64-105590723705278@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705273@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705273@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 19 Mar 2003 21:06:20 -0500, Jes Sorensen <jes@wildopensource.com> said:

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

  David> Why do you need to export it if you just use a light-weight
  David> gettimeofday()?  The light-weight syscall can readily access
  David> the ITC-drift info via kernel memory.

  Jes> Let me get sure I understand you right here, you are suggesting
  Jes> I add a new syscall to provide the info currently found in
  Jes> /proc/sal/itc_drift? Right now it's just returning true/false
  Jes> (1/0) as to whether the ITC drifts or not.

No, not at all.  I was simply suggesting to always use gettimeofday().
The light-weight implementation of gettimeofday() runs in ~130 cycles,
which isn't much slower than what you could do in user-level.

  Jes> what are you referring to by HPET?

HPET = High Precision Event Timer.  See:

  http://www.intel.com/labs/platcomp/hpet/hpetspec.htm

	--david

