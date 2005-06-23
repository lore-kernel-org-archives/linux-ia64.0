From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 23 Jun 2005 21:19:18 +0000
Subject: Re: [PATCH] pcibus_to_node implementation for IA64
Message-Id: <Pine.LNX.4.62.0506231418300.13272@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 23 Jun 2005, Alex Williamson wrote:

>    This will work, but there's no reason to hide this in the platform
> specific code.  The PCI root bridges are in ACPI namespace, a
> pxm_to_node() lookup should be done there when the buses are discovered.
> Then it would work on HP and DIG boxes.  Thanks,

Could you do that? We only provide minimal ACPI support which does not 
include pci. For our needs this will not work.


