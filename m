From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 28 Jan 2004 18:31:58 +0000
Subject: Re: [RFC/PATCH, 1/4] readX_check() performance evaluation
Message-Id: <16408.30.896895.980121@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a201c3e541$c0e7d680$2987110a@lsd.css.fujitsu.com>
	<20040128172004.GB5494@cup.hp.com>
	<20040128184137.616b6425.ak@suse.de>
In-Reply-To: <20040128184137.616b6425.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Grant Grundler <iod00d@hp.com>, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> On Wed, 28 Jan 2004 18:41:37 +0100, Andi Kleen <ak@suse.de> said:

  Andi> Also in my experience from AMD64 which originally was a bit
  Andi> aggressive on enabling MCEs: enabling MCEs increases your
  Andi> kernel support load a lot.

  Andi> Many people have slightly buggy systems which still happen to
  Andi> work mostly.  If you report every problem you as kernel
  Andi> maintainer will be flooded with reports about things you can
  Andi> nothing to do about.

I find this comment interesting.  Can you elaborate what you mean by
"slightly buggy systems"?

	--david
