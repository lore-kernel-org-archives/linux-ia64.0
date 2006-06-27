From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 27 Jun 2006 22:16:55 +0000
Subject: RE: [PATCH] fix prom revision checks in SN kernel
Message-Id: <617E1C2C70743745A92448908E030B2A27F845@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606271946.MAA19328@google.engr.sgi.com>
In-Reply-To: <200606271946.MAA19328@google.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Tony, hold up. I was just informed there is a patch in-play which
> will conflict with this one:
>
> http://marc.theaimsgroup.com/?l=linux-ia64&m3944733900687&w=2
>
> It removes the prom rev. check from
> drivers/pci/hotplug/sgi_hotplug.c replacing it with
> a sn_prom_feature_available() call. It's obviously
> the preferrable code.

That's not in my queue (he said in a slight panic) ... my recollection
of the "tollhouse" patches was that there was an ia64 bit (that I've
already sent to Linus), and some pci stuff that Prarit was going to
push to Greg.

> Should I resubmit without a change to drivers/pci/hotplug/sgi_hotplug.c?

Yes, please re-spin without this hunk (I'm feeling lazy today).

-Tony
