From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 28 Jan 2004 23:35:01 +0000
Subject: Re: [RFC/PATCH, 1/4] readX_check() performance evaluation
Message-Id: <16408.18213.790850.66687@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a201c3e541$c0e7d680$2987110a@lsd.css.fujitsu.com>
	<20040128172004.GB5494@cup.hp.com>
	<20040128184137.616b6425.ak@suse.de>
	<16408.30.896895.980121@napali.hpl.hp.com>
	<20040128195246.47a84498.ak@suse.de>
	<16408.3157.336306.812481@napali.hpl.hp.com>
	<20040128203915.22d84e8d.ak@suse.de>
	<16408.4597.123125.788631@napali.hpl.hp.com>
	<20040128210132.2b0e5a96.ak@suse.de>
In-Reply-To: <20040128210132.2b0e5a96.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: davidm@hpl.hp.com, davidm@napali.hpl.hp.com, iod00d@hp.com, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> On Wed, 28 Jan 2004 21:01:32 +0100, Andi Kleen <ak@suse.de> said:

  Andi> Seriously you can count it somewhere and present it in sysfs
  Andi> or /proc.  Or log it somewhere else and supply a special
  Andi> utility to show them that makes it clear that the events are
  Andi> hardware and not software related.  I suppose if your server
  Andi> vendor is serious they will supply a tool to read the firmware
  Andi> log from a running system.

  Andi> But printks enabled by default are a bad idea (and a bug too
  Andi> BTW - printk called from MCE handlers can randomly deadlock)

No argument here.  I didn't get/see the earlier part of this
discussion so I didn't realize you were complaining about printks
only.  Never mind.

	--david
