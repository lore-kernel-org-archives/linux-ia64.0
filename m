From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 06 Mar 2002 19:45:38 +0000
Subject: [Linux-ia64] psr.dt state when DO_SAVE_MIN is invoked
Message-Id: <marc-linux-ia64-105590701905232@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some systems running an old kernel (2.4.7) have been seen to
hang looping in an apparent recursive TLB fault.  The same tests
that locked up these machines seem to run fine on new kernels,
but while looking into the issue the following oddity was
noted in the code, that still exists in 2.4.18

in arch/ia64/kernel/ivt.S we have:
ENTRY(page_fault)
        ssm psr.dt
        ;;
        srlz.i
        ;;
        SAVE_MIN_WITH_COVER

and minstate.h defines:

#define SAVE_MIN_WITH_COVER     DO_SAVE_MIN(cover, mov rCRIFS=cr.ifs,)

which in turn says:

/*
 * DO_SAVE_MIN switches to the kernel stacks (if necessary) and saves
 * the minimum state necessary that allows us to turn psr.ic back
 * on.
 *
 * Assumed state upon entry:
 *      psr.ic: off
 *      psr.dt: off
 *      r31:    contains saved predicates (pr)
 *
	...

See how page_fault explicitly sets psr.dt, and then invokes a macro
that says that the assumed entry state is psr.dt should be off. Is
the comment just plain wrong, or is there a potential issue here?

The 2.4.7 failure hits at around the 67 hour mark in the tests, the
newer (RedHat 7.2 a.k.a. 2.4.9-18) kernel survives 72 hours ... but
that's as long as we scheduled the test to run.

-Tony

