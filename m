From: Paul Ionescu <i_p_a_u_l@yahoo.com>
Date: Tue, 26 Apr 2005 14:03:26 +0000
Subject: Re: [RFC/PATCH 0/3] ACPI based I/O APIC hot-plug
Message-Id: <pan.2005.04.26.14.03.23.413590@yahoo.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4267AD0E.3080006@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Hi Kenji,

On Thu, 21 Apr 2005 22:39:26 +0900, Kenji Kaneshige wrote:

> Hi,
> 
> Here is a set of patches to support ACPI based I/O APIC hotplug. This code
> consists of the following three patches.
> 
>     - Add the new interfaces for I/O APIC hot-add/hot-remove. The
>       implementation of these interfaces depends on each architecture.
> 
>     - IA64 implementation of above-mentioned interfeces for I/O APIC
>       hot-add/hot-remove.

Any plans for i386 implementation ?

> 
>     - Add I/O APIC hot-add support to ACPIPHP dirver. PCI root bridge
>       hot-add will be fully functional with this patch. This will be also
>       needed to support hot-add of p2p bridge hierarchy that contains I/O
>       APICs. This code supports only hot-add for now.
> 
> These patches support I/O APIC hot-plug on ia64 only for now. These are
> against 2.6.12-rc2-mm3.
> 
> Thanks,
> Kenji Kaneshige


