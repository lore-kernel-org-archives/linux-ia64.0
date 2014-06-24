From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 24 Jun 2014 17:56:09 +0000
Subject: RE: [PATCH v6 1/9] efi: Use early_mem*() instead of early_io*()
Message-Id: <3908561D78D1C84285E8C5FCA982C28F32846B97@ORSMSX114.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1403299768-9955-1-git-send-email-daniel.kiper@oracle.com>
 <1403299768-9955-2-git-send-email-daniel.kiper@oracle.com>
 <53A7F104020000780001C4BE@mail.emea.novell.com>
 <20140623135446.GG28489@olila.local.net-space.pl>
In-Reply-To: <20140623135446.GG28489@olila.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Kiper <daniel.kiper@oracle.com>, Jan Beulich <JBeulich@suse.com>
Cc: "andrew.cooper3@citrix.com" <andrew.cooper3@citrix.com>, "david.vrabel@citrix.com" <david.vrabel@citrix.com>, "ian.campbell@citrix.com" <ian.campbell@citrix.com>, "stefano.stabellini@eu.citrix.com" <stefano.stabellini@eu.citrix.com>, "jeremy@goop.org" <jeremy@goop.org>, "Fleming, Matt" <matt.fleming@intel.com>, "x86@kernel.org" <x86@kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "eshelton@pobox.com" <eshelton@pobox.com>, "mingo@redhat.com" <mingo@redhat.com>, "mjg59@srcf.ucam.org" <mjg59@srcf.ucam.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> I am CC'ing IA-64 guys.

The *_unmap() functions are no-op on ia64 - because we have mappings for everything all the time
- the *_map() functions just need to compute the proper address to use to get the right attributes
(so we don't mix and match cacheable and uncachable access to the same address). But there is
nothing to tear down afterwards.

I do tend to agree with Daniel that is seems odd to setup the mapping with one class of function
and then tear it down with another.

-Tony

