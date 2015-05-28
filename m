From: Yinghai Lu <yinghai@kernel.org>
Date: Thu, 28 May 2015 22:08:28 +0000
Subject: Re: [PATCH 2/2] PCI: pciehp: Convert pciehp to be builtin only, not modular
Message-Id: <CAE9FiQWDsQxKK3m4_-dSXm8V3xNc4oOtg2UQi=aayeKhLutwQg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20130725175242.6006.56007.stgit@bhelgaas-glaptop>
	<CAE9FiQXq59tSBM0SQ4OToXydZrRC3yukALmWEb6K9xpCGbdUhg@mail.gmail.com>
	<20150527193149.GD10210@google.com>
	<4269355.CI4MW738Od@vostro.rjw.lan>
In-Reply-To: <4269355.CI4MW738Od@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Bjorn Helgaas <bhelgaas@google.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mundt <lethal@linux-sh.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Wed, May 27, 2015 at 6:30 PM, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> On Wednesday, May 27, 2015 02:31:49 PM Bjorn Helgaas wrote:
> For debug you can always use pcie_ports=compat and that will disable
> pciehp too.

That will disable AER at the same time, right?.
