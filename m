From: Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Date: Thu, 28 Jan 2016 17:24:17 +0000
Subject: Re: [PATCH v9 3/6] arm64/arm, numa, dt: adding numa dt binding implementation for arm64 platforms.
Message-Id: <CAFpQJXVhEVw7vSq233wfkOGkTanf-msO+PEcWJ2OVAFUhn7n+w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1453134965-6125-1-git-send-email-gkulkarni@caviumnetworks.com>
	<1453134965-6125-4-git-send-email-gkulkarni@caviumnetworks.com>
	<20160126203603.GC17600@localhost>
	<20160128143925.GC775@arm.com>
In-Reply-To: <20160128143925.GC775-5wv7dgnIgG8@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>
Cc: Bjorn Helgaas <helgaas-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Ganapatrao Kulkarni <gkulkarni-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>, "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>, Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Leif Lindholm <leif.lindholm-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, rfranz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, "msalter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <msalter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Steve Capper <steve.capper-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Hanjun Guo <hanjun.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Al Stone <al.stone-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Ar

Hi Will,


On Thu, Jan 28, 2016 at 8:09 PM, Will Deacon <will.deacon@arm.com> wrote:
> On Tue, Jan 26, 2016 at 02:36:04PM -0600, Bjorn Helgaas wrote:
>> Subject is "arm64/arm, numa, dt: adding ..."  What is the significance
>> of the "arm" part?  The other patches only mention "arm64".
>>
>> General comment: the code below has little, if anything, that is
>> actually arm64-specific.  Maybe this is the first DT-based NUMA
>> platform?  I don't see other similar code for other arches, so maybe
>> it's too early to try to generalize it, but we should try to avoid
>> adding duplicates of this code if/when other arches do show up.
>
> Having it in the core code would allow us to share it with arch/arm/
> fairly straightforwardly.
This binding can be used for arm too.
however at this moment it is the need of arm64 platforms.
can we please keep this to arm64 as it's too early to try to
generalize it(as Bjorn suggested)
I prefer to keep it as it is, otherwise ok.
Please suggest.
>
> Will
thanks
Ganapat
