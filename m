From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Thu, 23 Sep 2004 06:55:39 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[3/6]-Mapping lsapic to cpu
Message-Id: <20040922235539.A8323@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com> <20040920093819.E14208@unix-os.sc.intel.com> <20040922111056.3360443c.tokunaga.keiich@jp.fujitsu.com>
In-Reply-To: <20040922111056.3360443c.tokunaga.keiich@jp.fujitsu.com>; from tokunaga.keiich@jp.fujitsu.com on Wed, Sep 22, 2004 at 11:10:56AM +0900
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Cc: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>, len.brown@intel.com, acpi-devel@lists.sourceforge.net, lhns-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 22, 2004 at 11:10:56AM +0900, Keiichiro Tokunaga wrote:
> On Mon, 20 Sep 2004 09:38:19 -0700 Keshavamurthy Anil S wrote:
> > ---
> > Name:acpi_hotplug_arch.patch
> > Status: Tested on 2.6.9-rc2
> > Signed-off-by: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
> > Depends:	
> > Version: applies on 2.6.9-rc2	
> > Description: 
> > This patch provides the architecture specifice support for mapping lsapic to cpu array.
> > Currently this supports just IA64. Support for IA32 and x86_64 is in progress
> > ---
> 
> Here is a small fix.
> 
> Thanks,
> Keiichiro Tokunaga
> 
> 
> Name: pxm_to_nid_map_fix.patch
> Status: Tested on 2.6.9-rc2
> Signed-off-by: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
> Description:
> Change an attribute of pxm_to_nid_map[] from __initdata to __devinitdata.

good catch:)
thanks,
Anil
