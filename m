From: Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Date: Tue, 26 Jan 2016 17:28:10 +0000
Subject: Re: [PATCH v9 2/6] Documentation, dt, arm64/arm: dt bindings for numa.
Message-Id: <CAFpQJXXtrZk19XBM=BTGZMgtNy-xppoG7NZ_nDAv=Nt5P62e6g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1453134965-6125-1-git-send-email-gkulkarni@caviumnetworks.com>
	<1453134965-6125-3-git-send-email-gkulkarni@caviumnetworks.com>
	<20160120141806.GA8434@rob-hp-laptop>
In-Reply-To: <20160120141806.GA8434@rob-hp-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Cc: Ganapatrao Kulkarni <gkulkarni-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>, "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Will Deacon <Will.Deacon-5wv7dgnIgG8@public.gmane.org>, Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>, Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Leif Lindholm <leif.lindholm-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, rfranz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, "msalter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <msalter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Steve Capper <steve.capper-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Hanjun Guo <hanjun.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Al Stone <al.stone-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Pawel

Hi Rob, Mark,


On Wed, Jan 20, 2016 at 7:48 PM, Rob Herring <robh@kernel.org> wrote:
> On Mon, Jan 18, 2016 at 10:06:01PM +0530, Ganapatrao Kulkarni wrote:
>> DT bindings for numa mapping of memory, cores and IOs.
>>
>> Reviewed-by: Robert Richter <rrichter@cavium.com>
>> Signed-off-by: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
>> ---
>>  Documentation/devicetree/bindings/arm/numa.txt | 272 +++++++++++++++++++++++++
>>  1 file changed, 272 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/arm/numa.txt
>
> This is looks okay to me, but some cosmetic things on the example.
can i have your Ack please?
>
>> +=======================================
>> +4 - Example dts
>> +=======================================
>> +
>> +2 sockets system consists of 2 boards connected through ccn bus and
>> +each board having one socket/soc of 8 cpus, memory and pci bus.
>> +
>> +     memory@00c00000 {
>
> Drop the leading 0s on unit addresses.
i will correct these in next version.
>
>> +             device_type = "memory";
>> +             reg = <0x0 0x00c00000 0x0 0x80000000>;
>> +             /* node 0 */
>> +             numa-node-id = <0>;
>> +     };
>> +
>> +     memory@10000000000 {
>> +             device_type = "memory";
>> +             reg = <0x100 0x00000000 0x0 0x80000000>;
>> +             /* node 1 */
>> +             numa-node-id = <1>;
>> +     };
>> +
>> +     cpus {
>> +             #address-cells = <2>;
>> +             #size-cells = <0>;
>> +
>> +             cpu@000 {
>
> Same here (leaving one of course).
>
>> +                     device_type = "cpu";
>> +                     compatible =  "arm,armv8";
>> +                     reg = <0x0 0x000>;
>> +                     enable-method = "psci";
>> +                     /* node 0 */
>> +                     numa-node-id = <0>;
>> +             };
>> +             cpu@001 {
>
> and so on...
>
>> +                     device_type = "cpu";
>> +                     compatible =  "arm,armv8";
>> +                     reg = <0x0 0x001>;
>
> Either all leading 0s or none.
>
>> +                     reg = <0x0 0x008>;
>> +                     enable-method = "psci";
>> +                     /* node 1 */
>
> Kind of a pointless comment.
>
> Wouldn't each cluster of cpus for a given numa node be in a different
> cpu affinity? Certainly not required by the architecture, but the common
> case at least.
>
>> +                     numa-node-id = <1>;
>> +             };
>
> [...]
>
>> +     pcie0: pcie0@0x8480,00000000 {
>
> Drop the 0x and the comma.
>
>> +             compatible = "arm,armv8";
>> +             device_type = "pci";
>> +             bus-range = <0 255>;
>> +             #size-cells = <2>;
>> +             #address-cells = <3>;
>> +             reg = <0x8480 0x00000000 0 0x10000000>;  /* Configuration space */
>> +             ranges = <0x03000000 0x8010 0x00000000 0x8010 0x00000000 0x70 0x00000000>;
>> +             /* node 0 */
>> +             numa-node-id = <0>;
>> +        };
>> +
>> +     pcie1: pcie1@0x9480,00000000 {
>
> ditto
>
>> +             compatible = "arm,armv8";
>> +             device_type = "pci";
>> +             bus-range = <0 255>;
>> +             #size-cells = <2>;
>> +             #address-cells = <3>;
>> +             reg = <0x9480 0x00000000 0 0x10000000>;  /* Configuration space */
>> +             ranges = <0x03000000 0x9010 0x00000000 0x9010 0x00000000 0x70 0x00000000>;
>> +             /* node 1 */
>> +             numa-node-id = <1>;
>> +        };
>> +
>> +     distance-map {
>> +             compatible = "numa-distance-map-v1";
>> +             distance-matrix = <0 0 10>,
>> +                               <0 1 20>,
>> +                               <1 1 10>;
>> +     };
>> --
>> 1.8.1.4
thanks
Ganapat
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe devicetree" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
