From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 10 Mar 2004 21:01:49 +0000
Subject: Re: IA32 programs make kernel stall on IPF machine when CONFIG_PREEMPT is enabled
Message-Id: <16463.33341.674672.75452@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3AA03342E913FA4BA6D8BD0732BFC74B05154D94@pdsmsx402.pd.intel.com>
In-Reply-To: <3AA03342E913FA4BA6D8BD0732BFC74B05154D94@pdsmsx402.pd.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 10 Mar 2004 12:40:00 +0800, "Zhang, Yanmin" <yanmin.zhang@intel.com> said:

  Yanmin> There is a bug in base kernel 2.6.3. When CONFIG_PREEMPT is
  Yanmin> enabled, all IA32 programs will make kernel stall on IPF
  Yanmin> machines.

Your mailer wraps long lines.  Either fix the mailer or, if necessary,
send patches as MIME attachments.

For this time, I fixed the line-wraps by hand and applied the patch.

Thanks,

	--david
