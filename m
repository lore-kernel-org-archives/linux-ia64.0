From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 14 Apr 2003 18:45:35 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.5.67)
Message-Id: <marc-linux-ia64-105590723705497@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 14 Apr 2003 21:55:19 +0900 (JST), Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp> said:

  Takayoshi> It seems that newly integrated PCI segment support is
  Takayoshi> incomplete.

Argh.  Alex, can you work this out?  If fixing the segment support is
too much effort right now, we need to revert the segment support so
the kernel boots on Big Sur (and Tiger) again.

	--david

