From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Tue, 26 Apr 2005 14:34:42 +0000
Subject: Re: [ACPI] Re: [RFC/PATCH 0/3] ACPI based I/O APIC hot-plug
Message-Id: <426E5182.70400@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4267AD0E.3080006@jp.fujitsu.com> <pan.2005.04.26.14.03.23.413590@yahoo.com>
In-Reply-To: <pan.2005.04.26.14.03.23.413590-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Ionescu <i_p_a_u_l-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Cc: acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Hi Paul,

Paul Ionescu wrote:
> Hi Kenji,
> 
> On Thu, 21 Apr 2005 22:39:26 +0900, Kenji Kaneshige wrote:
> 
> 
>>Hi,
>>
>>Here is a set of patches to support ACPI based I/O APIC hotplug. This code
>>consists of the following three patches.
>>
>>    - Add the new interfaces for I/O APIC hot-add/hot-remove. The
>>      implementation of these interfaces depends on each architecture.
>>
>>    - IA64 implementation of above-mentioned interfeces for I/O APIC
>>      hot-add/hot-remove.
> 
> 
> Any plans for i386 implementation ?
> 

I want to work on i386 implementation, but I don't have enough time for
this... I hope someone will also work on this area for i386.

Thanks,
Kenji Kaneshige
