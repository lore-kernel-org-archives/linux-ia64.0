From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 08 Mar 2004 19:10:01 +0000
Subject: RE: cat /proc/acpi/events bad for your system's health!
Message-Id: <16460.50441.461359.630173@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16455.50905.681007.50048@napali.hpl.hp.com>
In-Reply-To: <16455.50905.681007.50048@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 8 Mar 2004 13:21:34 +0800, "Yu, Luming" <luming.yu@intel.com> said:

  Luming> Regarding unalignment access issue, Bob have the following
  Luming> patch integrated into 20040220.  Would it help this cases?

The primary problem is not the unaligned access, it's an access to
a bogus address:

  >> kernel unaligned access to 0xffffffffffffffff,

Are you saying that /proc/acpi/events works for you as expected with
the updated ACPI?

	--david
