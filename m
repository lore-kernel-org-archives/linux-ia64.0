From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 28 Jan 2004 19:48:05 +0000
Subject: Re: [RFC/PATCH, 1/4] readX_check() performance evaluation
Message-Id: <16408.4597.123125.788631@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a201c3e541$c0e7d680$2987110a@lsd.css.fujitsu.com>
	<20040128172004.GB5494@cup.hp.com>
	<20040128184137.616b6425.ak@suse.de>
	<16408.30.896895.980121@napali.hpl.hp.com>
	<20040128195246.47a84498.ak@suse.de>
	<16408.3157.336306.812481@napali.hpl.hp.com>
	<20040128203915.22d84e8d.ak@suse.de>
In-Reply-To: <20040128203915.22d84e8d.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: davidm@hpl.hp.com, davidm@napali.hpl.hp.com, iod00d@hp.com, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> On Wed, 28 Jan 2004 20:39:15 +0100, Andi Kleen <ak@suse.de> said:

  >> Yet they are a good indicator that something is wrong (not performing
  >> properly) or may be failing soon.  I don't think putting on blinders
  >> for such problems is a good idea.  Though I agree that the question of

  Andi> Most server class hardware should log it somewhere and allow
  Andi> to read the event log in the firmware. This even works for
  Andi> unhandleable errors unlike what the OS could do.

And you'd want to reboot your server just so you can check on the soft
failure rate? ;-)

	--david
