From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 06 Jun 2002 16:35:13 +0000
Subject: RE: [Linux-ia64] [RFC] Multithreaded core dump for 2.5.10-ia64 ke
Message-Id: <marc-linux-ia64-105590701905649@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905644@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905644@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 6 Jun 2002 09:28:00 -0700 , "Gross, Mark" <mark.gross@intel.com> said:

  Mark> Good idea, I'll put the BUG_ON in.  I'll re-base to the
  Mark> updated 2.5.18 ia64 patches, that include perfmon_itanium.h,
  Mark> and add the BUG_ON logic later today.

Note that for 2.5.18, you'll also have to create an empty
include/asm-ia64/suspend.h, as Peter pointed out yesterday.
Sorry for the glitches.  Will try to do better next time.

	--david

