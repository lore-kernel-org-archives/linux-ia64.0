From: Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Date: Thu, 11 Feb 2016 15:58:48 +0000
Subject: Re: [PATCH v10 3/8] dt, numa: adding numa dt binding implementation.
Message-Id: <CAFpQJXU+fon8DY--qhyZV=JDv9omqs=c9eSX34g1J2w2uudNKA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454407763-1017-1-git-send-email-gkulkarni@caviumnetworks.com>
	<1454407763-1017-4-git-send-email-gkulkarni@caviumnetworks.com>
	<CAL_JsqK5HV9yzBE+ANnTw26eVR7Dy+B8OkwQ-7WF8KDa86Fd9g@mail.gmail.com>
	<20160211153255.GR24726@rric.localdomain>
In-Reply-To: <20160211153255.GR24726-vWBEXY7mpu582hYKe6nXyg@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robert Richter <robert.richter-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Ganapatrao Kulkarni <gkulkarni-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>, "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-metag <linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linuxppc-dev <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, SH-Linux <linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Will Deacon <Will.Deacon-5wv7dgnIgG8@public.gmane.org>, Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>, Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Leif Lindholm <leif.lindholm-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, rfranz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Mark Salter <msalter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Hi Rob,

On Thu, Feb 11, 2016 at 9:02 PM, Robert Richter
<robert.richter@caviumnetworks.com> wrote:
> On 11.02.16 08:50:41, Rob Herring wrote:
>> On Tue, Feb 2, 2016 at 4:09 AM, Ganapatrao Kulkarni
>> <gkulkarni@caviumnetworks.com> wrote:
>> > dt node parsing for numa topology is done using device property
>> > numa-node-id and device node distance-map.
>>
>> How is it that powerpc doesn't need flat DT parsing for NUMA? Both
>> arches are memblock based and the binding is similar IIRC, so you
>> should be able to find a way to do this with the unflattened tree.
>> Ideally, there should be some common code shared as well.

powerpc has implemented numa binding using property named
"ibm,associativity", we too started adding using the same binding[
refer version V6]
however had discussion/review with Mark R about mapping and we could not map to
some of the topology like mesh and ring topology.

So we have defined and implemented this new binding which is simple
and scalable.
This binding is very much aligned to ACPI NUMA specification.

>>
>> Do you have a git tree with this series?
>
> I have pushed it here for you:
>
>  https://git.kernel.org/cgit/linux/kernel/git/rric/linux.git/log/?h=thunder/numa-v10

thanks Robert.
>
> -Robert

thanks
Ganapat
