From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 16 Jul 2003 15:25:07 +0000
Subject: Re: FW: BUG on 2.5.74 for Tiger4
Message-Id: <marc-linux-ia64-105836945607691@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 16 Jul 2003 16:39:29 +0800, "Yu, Luming" <luming.yu@intel.com> said:

  Luming> Is it known issue? (The tree is pulled from
  Luming> http://lia64.bkbits.net/linux-ia64-2.5
  Luming> <http://lia64.bkbits.net:8080/linux-ia64-2.5> yesterday).

  Luming> "Kernel BUG at timer.c:380!"

  Luming> This bug appears randomly. Sometimes after 'su', sometimes
  Luming> simply after "ls"

Depends on _when_ you pulled it yesterday.  There were some per-CPU
bugs left that could cause this.  But as of yesterday afternoon, this
should be all fixed (the proper way).

	--david

PS: Please don't send HTML this mailing list.  No need to waste
    bits...
