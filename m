From: "Tian, Kevin" <kevin.tian@intel.com>
Date: Fri, 14 Apr 2006 04:45:30 +0000
Subject: RE: Two questions about iosapic code
Message-Id: <571ACEFD467F7749BC50E0A98C17CDD8094E7B19@pdsmsx403>
List-Id: <linux-ia64.vger.kernel.org>
References: <571ACEFD467F7749BC50E0A98C17CDD8094E7B15@pdsmsx403>
In-Reply-To: <571ACEFD467F7749BC50E0A98C17CDD8094E7B15@pdsmsx403>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>From: Kenji Kaneshige [mailto:kaneshige.kenji@jp.fujitsu.com]
>Sent: 2006=C4=EA4=D4=C214=C8=D5 12:38
>Hi Kevin,
>
>> If two RTEs are from two different IOSAPIC, above code is
>> meaningful to send two EOI to both IOSAPIC. However if two
>> RTEs are in same IOSAPIC, then EOI are sent to same IOSAPIC
>> twice. Will the 2nd EOI trigger duplicated notifications to CPU if
>> some device has assertion on that irq line once after 1st EOI?
>>
>
>I think it will, though I guess the 1st notification and 2nd
>notification might be handled as one interrupt, if 2nd notification
>was sent before reading IVR for 1st notification. On the other hand,
>2nd interrupt would be handled like spurious interrupt, when 1st one
>and 2nd one were handled separately. Anyway, 2nd EOI looks needless
>and I think it should be fixed.

Ah yes, normally it's harmless since CR.EOI is written after sending
IOSAPIC.EOI which ensures two consequent notifications as one=20
pending to processor.

>
>
>> - iosapic_reassign_vector:
>> 	It's only called by iosapic_register_platform_intr for PMI by
>> far.
>> When designated vector is already occupied, the rte list of that
>> vector will be copied to a new vector. However there's no updates
>> to physical RTEs within IOSAPIC to reflect this change.
>
>IIRC, vectors for PMI are 0 to 15 and any other external interrupts
>don't use those vectors. So this code path is executed only if
>multiple PMIs use the same vector number. Vector numbers for PMIs
>are assigned by firmware, so OS cannot re-assign other vector. I
>guess this is why there's no updates to physical RTES. But, I don't
>know why we need iosapic_reassing_vector()...

OK, I see. The name here is a bit misleading... :-)

Thanks a lot,
Kevin
