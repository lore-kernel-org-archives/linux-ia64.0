From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 Jul 2004 23:29:22 +0000
Subject: Re: print CPU number when warning of hazards
Message-Id: <16629.49618.280445.44139@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F5AAA8.5020500@sgi.com>
In-Reply-To: <40F5AAA8.5020500@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 14 Jul 2004 16:50:32 -0500, Joshua Aas <josha@sgi.com> said:

  Joshua> Hello, The following patch would be useful for diagnostics.

Why does the CPU help there?  Depenency-violations are specific to
code, so why would the CPU matter?  Apart from that, have you actually
ever seen that message show up?

	--david
