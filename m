From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 02 Aug 2001 01:13:14 +0000
Subject: Re: [Linux-ia64] Panic in linuxrc (2.4.7)
Message-Id: <marc-linux-ia64-105590693005988@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005983@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005983@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 1 Aug 2001 16:15:43 -0700, David Mosberger <davidm@hpl.hp.com> said:

  David> Do you have CONFIG_PERFMON enabled?  If not, try turning it
  David> on.  We are investigating the problem.  It looks to be a
  David> Heisenbug: the problem gets triggered depending on what the
  David> exact code layout is.  Adding or removing a single bundle in
  David> the right place seems to make the difference...

OK, this turns out to be due to an assembler bug: the assembler fails
to put a stop bit in front of an "alloc" instruction if the "alloc" is
preceded by a .align directive and the directive inserts one or more
"nop" bundles. ;-(

This bug was difficult to track down because it got triggered while
psr.ic was cleared, which means that the IP reported in the tombstone
is all wrong and there is no easy way to find out at which address the
real fault occurred.  Well, at least the workaround is easy:

--- arch/ia64/kernel/entry.S-orig	Wed Aug  1 12:48:26 2001
+++ arch/ia64/kernel/entry.S	Wed Aug  1 18:05:31 2001
@@ -687,7 +687,7 @@
 	shladd in0=loc1,3,r17
 	mov in1=0
 	;;
-	.align 32
+//	.align 32
 rse_clear_invalid:
 	// cycle 0
  { .mii

Please try again with this patch applied.

	--david

