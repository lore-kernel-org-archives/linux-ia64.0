From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 27 Apr 2004 00:32:18 +0000
Subject: Re: [RFC IA64 Hotplug] [Patch 3/7] sysfs_ia64.patch
Message-Id: <16525.43538.319708.481784@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ORSMSX4041XvpFVjCRG00000170@orsmsx404.amr.corp.intel.com>
In-Reply-To: <ORSMSX4041XvpFVjCRG00000170@orsmsx404.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 27 Apr 2004 10:20:55 +1000, Rusty Russell <rusty@rustcorp.com.au> said:

  Rusty> On Tue, 2004-04-27 at 08:03, David Mosberger wrote:
  >> >>>>> On Sat, 24 Apr 2004 23:46:34 -0700, "Ashok Raj"
  >> <ashok.raj@intel.com> said:

  Ashok> +static DEFINE_PER_CPU(struct ia64_cpu, cpu_devices);
  >>  This seems to be ~100 bytes per CPU.  With 128 CPUs, that's
  >> ~13KB out of a max of 64KB.  Just a heads up...

  Rusty> David, you had me going there for a while.

  Rusty> It's 100 bytes out of 64k, because there's 64k per-cpu,
  Rusty> right?

Duh.  It's Monday, what can i say! ;-)

	--david
