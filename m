From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 May 2003 06:44:37 +0000
Subject: Re: [Linux-ia64] gettimeoffset for 2.5.67
Message-Id: <marc-linux-ia64-105590723705749@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705684@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705684@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 12 May 2003 22:05:02 -0400, Jes Sorensen <jes@wildopensource.com> said:

  Jes> As for the instruction bundling, yes of course I checked that, how can
  Jes> you ask ;-) The patch results in a total of three nops before the
  Jes> branch, however no matter how I move it around, getting rid of those
  Jes> doesn't seem to be possible (feel free to challenge me on that one).

This:

+	and r2=IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT,r2
 	;;
+	cmp.ne p8, p0=0, r2
+(p8)	br.spnt.many fsys_fallback_syscall


can be shortened to:

	tbit.nz p8, p0=IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT_BIT, r2
(p8)	br.spnt.many fsys_fallback_syscall

Might make it a bit easier to schedule things around (just add foo_BIT
numbers for all the SAL_PLATFORM_FEATURE bits and then define the
masks in terms of these bit numbers).

Sorry I didn't catch this previously.

	--david

