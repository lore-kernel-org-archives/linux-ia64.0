From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 26 Jun 2004 01:29:17 +0000
Subject: Re: [PATCH] Quiet corrected errors (CMC/CPE)
Message-Id: <16604.53613.948268.775937@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <0HZS006RBU9VGJ@fjmail504.fjmail.jp.fujitsu.com>
In-Reply-To: <0HZS006RBU9VGJ@fjmail504.fjmail.jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 24 Jun 2004 15:05:55 +0900, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> said:

  Hidetoshi> Hi, I think we don't always need this message to printk.

  Hidetoshi> Is it better to have a choice between a daemon-A which
  Hidetoshi> quickly alerts a user to the error or a daemon-B which
  Hidetoshi> silently takes the error statistic, or a quiet with no
  Hidetoshi> daemon?

OK, with me, but needs blessing from Tony (plus "Signed-off-by" trailers).

	--david
