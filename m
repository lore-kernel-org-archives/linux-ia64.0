From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 23 Jan 2012 18:23:56 +0000
Subject: RE: [PATCH 2/3] ACPI, APEI: Add RAM mapping support to ACPI
Message-Id: <3908561D78D1C84285E8C5FCA982C28F0282EE@ORSMSX104.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201201231651.23270.trenn@suse.de>
In-Reply-To: <201201231651.23270.trenn@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Renninger <trenn@suse.de>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Myron Stowe <myron.stowe@redhat.com>, "lenb@kernel.org" <lenb@kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "rjw@sisk.pl" <rjw@sisk.pl>, "Huang, Ying" <ying.huang@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> Is there any Itanium out there implementing any APEI table?
> Will there ever be one?

With respect to the EINJ table - the answer is definitely no.
Itanium has a PAL mechanism for injecting errors, so there is
no need to implement EINJ.

-Tony
