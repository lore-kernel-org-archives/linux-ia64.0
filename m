From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 26 Apr 2004 22:03:54 +0000
Subject: Re: [RFC IA64 Hotplug] [Patch 3/7] sysfs_ia64.patch
Message-Id: <16525.34634.498425.378536@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ORSMSX4041XvpFVjCRG00000170@orsmsx404.amr.corp.intel.com>
In-Reply-To: <ORSMSX4041XvpFVjCRG00000170@orsmsx404.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 24 Apr 2004 23:46:34 -0700, "Ashok Raj" <ashok.raj@intel.com> said:

  Ashok> +static DEFINE_PER_CPU(struct ia64_cpu, cpu_devices);

This seems to be ~100 bytes per CPU.  With 128 CPUs, that's ~13KB out
of a max of 64KB.  Just a heads up...

	--david
