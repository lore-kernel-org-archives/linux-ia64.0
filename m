From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 28 Jan 2004 19:24:05 +0000
Subject: Re: [RFC/PATCH, 1/4] readX_check() performance evaluation
Message-Id: <16408.3157.336306.812481@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a201c3e541$c0e7d680$2987110a@lsd.css.fujitsu.com>
	<20040128172004.GB5494@cup.hp.com>
	<20040128184137.616b6425.ak@suse.de>
	<16408.30.896895.980121@napali.hpl.hp.com>
	<20040128195246.47a84498.ak@suse.de>
In-Reply-To: <20040128195246.47a84498.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: davidm@hpl.hp.com, davidm@napali.hpl.hp.com, iod00d@hp.com, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> On Wed, 28 Jan 2004 19:52:46 +0100, Andi Kleen <ak@suse.de> said:

  >> I find this comment interesting.  Can you elaborate what you mean by
  >> "slightly buggy systems"?

  Andi> e.g. one bit ECC errors in memory are quite common.  And with
  Andi> ECC memory they are not really fatal.

Yet they are a good indicator that something is wrong (not performing
properly) or may be failing soon.  I don't think putting on blinders
for such problems is a good idea.  Though I agree that the question of
how to report such things without needlessly alerting Joe Clueless is
an interesting challenge.

	--david
