From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 15 Jul 2004 17:46:17 +0000
Subject: Re: print CPU number when warning of hazards
Message-Id: <16630.49897.438204.213719@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F5AAA8.5020500@sgi.com>
In-Reply-To: <40F5AAA8.5020500@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 15 Jul 2004 09:57:27 -0500, Joshua Aas <josha@sgi.com> said:

  Joshua> The idea was that it would be useful for hardware debugging
  Joshua> - if bad hardware tripped that code then one could see what
  Joshua> CPU it was on. Adding the CPU number there would be trivial
  Joshua> because a printk already exists. However, after further
  Joshua> discussions I've decided to pursue another solution which I
  Joshua> will probably post about later. Adding the CPU number where
  Joshua> my patch did raises the argument of "then why not do that
  Joshua> everywhere error conditions that could be hardward related
  Joshua> come up?"

Exactly.

I'll leave the code as it is, then.

Thanks,

	--david
