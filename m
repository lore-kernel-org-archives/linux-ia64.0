From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 12 May 2003 23:40:11 +0000
Subject: Re: [Linux-ia64] gettimeoffset for 2.5.67
Message-Id: <marc-linux-ia64-105590723705740@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705684@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705684@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 11 May 2003 13:54:29 -0400, Jes Sorensen <jes@wildopensource.com> said:

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:
>>>>> On Thu, 8 May 2003 12:44:47 -0400, Jes Sorensen <jes@wildopensource.com> said:

  Jes> I have added the check to fsys.S so for now we will stick to
  Jes> the slow version for SN2, but I may look into fixing it to use
  Jes> the fast syscalls for that at a later point. But lets get the
  Jes> kernel booting first ... details, details ;-)

  Jes> diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-vanilla/arch/ia64/kernel/fsys.S linux-2.5.69-030509/arch/ia64/kernel/fsys.S
  Jes> --- linux-2.5.69-030509-vanilla/arch/ia64/kernel/fsys.S	Sun May  4 19:52:48 2003
  Jes> +++ linux-2.5.69-030509/arch/ia64/kernel/fsys.S	Sun May 11 13:19:24 2003
  Jes> @@ -142,21 +142,31 @@
  Jes>   *	   we ought to either skip the ITC-based interpolation or run an ntp-like
  Jes>   *	   daemon to keep the ITCs from drifting too far apart.
  Jes>   */
  Jes> +
  Jes> +#define IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT	 	(1 << 3)
  Jes> +

This is not good.  The definition is already in sal.h.  Please lets
fix sal.h instead so it can be included by assembly code (i.e., change
sal.h so that the #define's come first, then check for #ifndef
__ASSEMBLY__".  Also, what's the impact of adding the the extra check
to the fsys_gettimeofday()?  Did you verify that the resulting
bundling is still near optimal?

Also, (not in reference to this particular patch): when you send code
that calls through a function pointer, I'd really like to see the
dereferencing there (for anything that goes in arch/ia64 or
include/asm-ia64, I mean).  I know some kernel folks feel differently
about this, but it's very misleading to write:

	foo(...);

instead of

	(*foo)(...);

The former cannot reasonably fail (in the absence of weak symbols),
whereas the latter certainly can (and usually seems to... ;-).

Thanks,

	--david

