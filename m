From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 06 Apr 2005 05:10:14 +0000
Subject: Re: [Gelato-technical] Serious performance degradation on a RAID with kernel 2.6.11
Message-Id: <16979.28470.481137.448621@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16978.62532.841151.100745@napali.hpl.hp.com>
In-Reply-To: <16978.62532.841151.100745@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 6 Apr 2005 13:53:23 +0900, Duraid Madina <duraid@kinoko.c.u-tokyo.ac.jp> said:

  Duraid> On Tue, Apr 05, 2005 at 09:45:34PM -0700, David Mosberger
  Duraid> wrote:
  >> >>>>> On Wed, 6 Apr 2005 11:13:30 +0900, Duraid Madina
  >> <duraid@kinoko.c.u-tokyo.ac.jp> said:

  >> Did you compile the driver as a module?

  Duraid> Nope. You're not seeing the problem?

I see it with 2.6.11 (38MB/s). 2.6.12-rc2 is definitely better
(53MB/s) but IIRC we used to be closer to 60MB/s, so perhaps something
still isn't quite optimal.

	--david
