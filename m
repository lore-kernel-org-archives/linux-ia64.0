From: Pavel Machek <pavel@suse.cz>
Date: Mon, 16 Feb 2004 10:19:24 +0000
Subject: Re: [RFC/PATCH, 1/4] readX_check() performance evaluation
Message-Id: <20040216101924.GA335@elf.ucw.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a201c3e541$c0e7d680$2987110a@lsd.css.fujitsu.com> <20040128172004.GB5494@cup.hp.com> <20040128184137.616b6425.ak@suse.de> <16408.30.896895.980121@napali.hpl.hp.com> <20040128195246.47a84498.ak@suse.de> <16408.3157.336306.812481@napali.hpl.hp.com> <20040128203915.22d84e8d.ak@suse.de>
In-Reply-To: <20040128203915.22d84e8d.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: davidm@hpl.hp.com, davidm@napali.hpl.hp.com, iod00d@hp.com, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Hi!

> But when printed in Linux they will report it to the linux maintainer or their 
> distribution vendor.  "My Linux is buggy and giving these weird messages" And they
> are both in no position at all to do something about it. 

What about new KERN_HWBUG loglevel?
									Pavel
-- 
When do you have a heart between your knees?
[Johanka's followup: and *two* hearts?]
