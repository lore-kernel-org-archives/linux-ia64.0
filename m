From: "Nguyen, Tom L" <tom.l.nguyen@intel.com>
Date: Mon, 07 Mar 2005 23:03:42 +0000
Subject: RE: PCI Express
Message-Id: <C7AB9DA4D0B1F344BF2489FA165E502407F62E52@orsmsx404.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, March 07, 2005 12:41 PM Colin Ngam wrote:
> I looked at Documentation/MSI-HOWTO.txt(linux-ia64-release-2.6.11) and

> it mentioned that CONFIG_X86_LOCAL_APIC has to be configured.  I did
not 
> find this configured on in any sample ia64 config files, but it does 
> exist in defconfig for i386.  Is this just an ia32 config option?

IA64 uses SAPIC instead of IOxAPIC. SAPIC, which is somewhat similar to
IOxAPIC, is included in IA64 kernel. MSI/MSI-X support configuration
option therefore is always available in IA64.

Thanks,
Long
