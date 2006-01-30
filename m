From: Prarit Bhargava <prarit@sgi.com>
Date: Mon, 30 Jan 2006 20:43:28 +0000
Subject: Re: boot-time slowdown for measure_migration_cost
Message-Id: <43DE7A70.8030004@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601271403.27065.bjorn.helgaas@hp.com> <20060130172140.GB11793@elte.hu> <20060130185301.GA4622@agluck-lia64.sc.intel.com> <20060130192438.GA29129@elte.hu> <20060130200026.GA5081@agluck-lia64.sc.intel.com>
In-Reply-To: <20060130200026.GA5081@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Bjorn Helgaas <bjorn.helgaas@hp.com>, Ingo Molnar <mingo@redhat.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>


Tony,

> 
> 
> Might it be wise to see whether the 2% variation that I saw can be
> repeated on some other architecture?   Can someone else try
> this patch and post the before/after values for migration_cost from dmesg?
> 



Ask and ye shall receive ... on the 64p/64G system.

Pristine:

[    9.942253] Brought up 64 CPUs
[    9.942904] Total of 64 processors activated (143654.91 BogoMIPS).
[    9.943995] build_sched_domains: start
[   32.108439] migration_cost=0,32232,39021
[   37.894391] build_sched_domains: end

Patched:

[    0.001307] Calibrating delay loop... 2244.60 BogoMIPS (lpjD89216)
[    9.942308] Brought up 64 CPUs
[    9.942812] Total of 64 processors activated (143654.91 BogoMIPS).
[   18.080441] migration_cost=0,31934,38750
[   23.865993] checking if image is initramfs... it is

P.

