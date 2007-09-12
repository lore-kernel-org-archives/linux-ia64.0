From: Matthew Garrett <mjg59@srcf.ucam.org>
Date: Wed, 12 Sep 2007 08:56:51 +0000
Subject: Re: [patch 2/2] ia64: add driver for ACPI methods to call native firmware
Message-Id: <20070912085650.GA3015@srcf.ucam.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200709111714.57095.bjorn.helgaas@hp.com> <200709111716.47194.bjorn.helgaas@hp.com>
In-Reply-To: <200709111716.47194.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

On Tue, Sep 11, 2007 at 05:16:46PM -0600, Bjorn Helgaas wrote:
> +config IA64_HP_AML_NFW
> +	tristate "Support ACPI AML calls to native firmware"

The description seems a bit generic for something that's HP specific?
-- 
Matthew Garrett | mjg59@srcf.ucam.org
