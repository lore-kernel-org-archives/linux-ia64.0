From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jul 2003 17:43:50 +0000
Subject: Re: kdb v4.3 for 2.5.72 ia64
Message-Id: <marc-linux-ia64-105785941223495@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105784864810217@msgid-missing>
In-Reply-To: <marc-linux-ia64-105784864810217@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 10 Jul 2003 16:50:27 +0200 (DFT), Xavier Bru <Xavier.Bru@bull.net> said:

  Xavier> Hello all,

  Xavier> I updated the previous port of kdb on 2.5.72 ia64 to kdb
  Xavier> v4.3 on: http://www.bullfreeware.com/linux/kdb

  Xavier> It has same limitations, just a fix for calling bh_enable()
  Xavier> only when interrupts are enabled (Problem is seen on 2.5
  Xavier> when kdb() is called from kdb_ipi(), due to WARN_ON() in
  Xavier> this code, but also exists in 2.4).

  Xavier> Hoping this can help. Please don't expect too much fixes
  Xavier> from me until september.

Cool!

Now if only somebody would do kgdb for ia64... ;-)

	--david
