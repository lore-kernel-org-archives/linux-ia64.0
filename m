From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jan 2002 23:37:17 +0000
Subject: RE: [Linux-ia64] [PATCH]  Support for alternative kernel profiler
Message-Id: <marc-linux-ia64-105590698805803@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805742@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805742@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 10 Jan 2002 15:26:58 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> We don't currently have any way for different software
  Tony> packages to share the performance counters, so it's very
  Tony> likely that there would be interactions with Stephane's PMU
  Tony> code (e.g. I rewrite cr.pmv to a new vector and re-write all
  Tony> of the pmc[] and pmd[] registers for my own purposes ... this
  Tony> will upset Stephane's code, similarly my code does not expect
  Tony> anyone else to touch any PMU registers, or fiddle with
  Tony> psr.pp/dcr.pp).

  Tony> It would probably be safest to turn off CONFIG_PERFMON in a
  Tony> kernel that is going to load an alternate profiler ... my
  Tony> profiler seems to cope ok provided nobody calls
  Tony> sys_perfmonctl().

This hardly seems like an ideal solution.  If you just want to keep
your patch for yourself, that's probably OK, but if it is to become
part of the kernel, we should look into a way for safely sharing the
PMU.  The first obvious way to try is to do the profiling you want on
top of perfmon.

	--david

