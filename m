From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 21 Dec 2005 22:09:13 +0000
Subject: new 2.6.15-rc6 perfmon2 patch
Message-Id: <20051221220913.GC8275@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051215104604.GA16937@frankl.hpl.hp.com> <20051220180744.GC5516@frankl.hpl.hp.com>
In-Reply-To: <20051220180744.GC5516@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfctr-devel@lists.sourceforge.net
Cc: perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

I have released YET another version of the perfmon2 new code base.
This one is STILL relative to 2.6.15-rc6 and is called 2.6.15-rc6-v2.
This one DOES fix the panic on pfm_fmt_put()!

This patch includes compared to initial 2.6.15-rc6:

    - quick overview of perfmon2 README

    - fix the kernel panic on pfm_fmt_put()

    - save/restore of PMU state when NMI watchdog is
      enabled.

    - reinforced  checks in register_smpl_fmt()

    - revised checks to detect if a format/PMU description is
      builtin or module

    - sampling formats can now export the notification
      message queue depth they require.

    - MIPS patch updated to latest fixes.

You MUST use libpfm-3.2-051215 with this kernel due to
interface change for pfm_create_context().
As usual, you can download the latest packages from the
SourceForge website at:

http://www.sf.net/projects/perfmon2

This will hopefully be the last release for this year.

Happy Holidays.

-- 
-Stephane
