From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Jul 2002 01:10:11 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905807@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 22 Jul 2002 16:54:23 -0700, Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp> said:

  Kimio> Hi, On Sat, 20 Jul 2002 00:08:22 -0700 David Mosberger
  Kimio> <davidm@napali.hpl.hp.com> wrote:

  >> The latest ia64 kernel patch is at
  >> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/ in file:
  >> 
  >> linux-2.4.18-ia64-020719.diff.gz

  Kimio> In this version, my system doesn't boot without increasing
  Kimio> swiotlb.  It was able to boot with default swiotlb in the
  Kimio> previous version.

  Kimio> I found eepro100 driver was trying to get swiotlb of (0x610
  Kimio> bytes * 1024 = 0x184000) at booting, and this caused swiotlb
  Kimio> shortage.

  Kimio> I guess the problem might be caused by this modification;

  >> - Include eepro1000 and Tigon3 support (various, plus bug fixes
  >> by Grant Grundler for these and other gigE cards)

  Kimio> In linux-2.4.18/drivers/net/eepro100.c, RX_RING_SIZE is
  Kimio> changed to 1024!!

Argh, I'm sorry about that.  This wasn't my intention.  I think I
misread e100 and e1000 and picked that one up by accident.

I'll fix that and update the 2.4.18 patch shortly.  I would like to
have a final 2.4.18 patch without silly issues like these.  (Assuming
2.4.19 shows up relatively soon).

	--david

