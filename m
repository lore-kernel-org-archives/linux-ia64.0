From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 Apr 2004 22:48:09 +0000
Subject: Re: proposed gcc/gas -mb-step changes
Message-Id: <16508.28201.916283.528284@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1081840653.1046.64.camel@leaf.tuliptree.org>
In-Reply-To: <1081840653.1046.64.camel@leaf.tuliptree.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 13 Apr 2004 00:17:32 -0700, Jim Wilson <wilson@specifixinc.com> said:

  Jim> Zack Weinberg of CodeSourcery sent mail to the binutils mailing
  Jim> list which proposes to add a new -mb-step option to the
  Jim> assembler.  Currently, gas will always give warnings if given
  Jim> code which triggers an Itanium (Merced) B-step errata.  The
  Jim> proposal is to only warn when the new -mb-step option is used.
  Jim> Also, this means that the existing gcc option -mb-step will
  Jim> have to pass -mb-step to the assembler.  The discussion is here
  Jim> http://sources.redhat.com/ml/binutils/2004-04/msg00187.html

  Jim> The linux kernel is the only code I know of that uses the gcc
  Jim> -mb-step option.  This is used if you configure with B-step
  Jim> support enabled.  This change means that the kernel should be
  Jim> modified to add -mb-step to aflags when the B-step support is
  Jim> enabled, just like it currently does for cflags.  Gas will fail
  Jim> if given a -m option it doesn't recognize, so this means that
  Jim> these changes will only work with new assembler versions.  I am
  Jim> assuming that use of the B-step support is rare enough that
  Jim> this won't be a problem.

Seems like an acceptable solution to me.

IIRC, the Errata being worked around by -mb-step was exceedingly rare
to trigger and I'm not even sure it was ever observed to trigger in a
realworld situation.  If so, perhaps it would be OK to drop -mb-step
entirely.  That would cause a small risk for users of B-step Itanium
(Merced) CPUs, but I can't imagine anyone is doing anything
"mission-critical" on prototype machines anyhow.  For testing etc.,
the a kernel compiled without -mb-step should still be usable, AFAIK.

	--david
