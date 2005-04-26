From: Andrew Morton <akpm@osdl.org>
Date: Tue, 26 Apr 2005 10:35:03 +0000
Subject: Re: [RFC/PATCH 0/3] ACPI based I/O APIC hot-plug
Message-Id: <20050426033503.3fd6b84c.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4267AD0E.3080006@jp.fujitsu.com>
	<20050426025716.142c5726.akpm@osdl.org>
	<426E15DA.9030800@jp.fujitsu.com>
In-Reply-To: <426E15DA.9030800@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Cc: len.brown@intel.com, tony.luck@intel.com, greg@kroah.com, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, pcihpd-discuss@lists.sourceforge.net

Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com> wrote:
>
> Andrew Morton wrote:
>  > "Kenji Kaneshige" <kaneshige.kenji@jp.fujitsu.com> wrote:
>  > 
>  >>Here is a set of patches to support ACPI based I/O APIC hotplug.
>  > 
>  > 
>  > OK, with the help of Tony's git tree I managed to get those merged up.
>  > 
> 
>  Wow, great!
>  But I'm now updating these patches based on the feedbacks.
>  How should I do about this? Should I send these updates as
>  another cleanup patch?

Replacement patches would be OK at this time.  Incremental patches are
preferred once the code settles down a bit, so we can see what changed.

