From: Tony Luck <tony.luck@gmail.com>
Date: Tue, 09 Jul 2013 20:29:15 +0000
Subject: Re: [PATCH] [IA64] Change CONFIG_HOTPLUG_PCI_ACPI=m to =y
Message-Id: <CA+8MBbKxMUfFmdB0mzrgf1GB68+=m+aFD0eJPwtoOF1gpBGTaw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20130702181019.27983.48289.stgit@bhelgaas-glaptop>
In-Reply-To: <20130702181019.27983.48289.stgit@bhelgaas-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 2, 2013 at 11:10 AM, Bjorn Helgaas <bhelgaas@google.com> wrote:
> After 6037a803b0, CONFIG_HOTPLUG_PCI_ACPI is a bool (it's no longer
> possible to configure acpiphp as a module).  These defconfig changes
> fix some build warnings.

Applied - Thanks Bjorn

-Tony
