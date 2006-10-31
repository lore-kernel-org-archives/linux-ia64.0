From: Jay Lan <jlan@sgi.com>
Date: Tue, 31 Oct 2006 08:59:49 +0000
Subject: Re: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
Message-Id: <45471085.3040408@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4546623D.5000105@engr.sgi.com>
In-Reply-To: <4546623D.5000105@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Zou, Nanhai wrote:
>> -----Original Message-----
>> From: Jay Lan [mailto:jlan@sgi.com]
>> Sent: 2006=C4=EA10=D4=C231=C8=D5 10:53
>> To: Zou, Nanhai
>> Cc: fastboot; Linux-IA64; Jack Steiner; Luck, Tony
>> Subject: Re: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
>>
>> Zou, Nanhai wrote:
>>>> -----Original Message-----
>>>> From: Jay Lan [mailto:jlan@engr.sgi.com]
>>>> Sent: 2006A"=A8=BA10O^A^31E`O~ 4:36
>>>> To: fastboot
>>>> Cc: Linux-IA64; Zou, Nanhai; Jack Steiner; Luck, Tony
>>>> Subject: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
>>>>
>>>> This patch is to fix a problem of interrupts being sent to cpus
>>>> that can not respond.
>>>>
>>>> This patch would return slave cpus to SAL slave loop, at time of
>>>> crash, except cpu0. The cpu0 is a special case as there is no way
>>>> to return it to SAL, so cpu0 is better handled in firmware.
>>>>
>>>> Signed-off-by: Jay Lan <jlan@sgi.com>
>>>>
>>>
>>> Does this fix the I/O interrupt redirect issue on SN?
>> This fixes the interrupts being sent to cpus not in the
>> slave loop that caused hang on SN. When one boots up the
>> kexec'ed kernel with 'maxcpus=3D1', all idle cpus needs to
>> be sent back. If they are not returned to the SAL slave
>> loop and just looping in cpu_relax(), they are considered
>> alive, but interrupts would be lost and system hang.
>>
>=20
>  But this will rely on machine crash on CPU 0?

We do not rely on machine crash on CPU 0 any more. If the
crashing CPU is not cpu 0 and the cpu 0 not being returned to
the slave loop, this case is handled by our PROM now.

However, if somebody tries to boot up a production kernel using '-le'
option _after_ the kexec'ed kernel is up running, the third kernel
would not boot unless we boot up the second kernel with cpu 0. I
posted a question on "if running 'kexec -le' on a kexec'ed kdump
kernel is legal" earlier and Vivek responded saying the scenario
is not guranteed to work. So, i think we are fine here.


>  Current Kdump will boot to second kernel on the crashing CPU.=20
>  So if machine crash and boot on CPU N, CPU 0 will still not be able to r=
edirect interrupt, right? =20

Yes, and this case is handled in our PROM.

>=20
>> This is different from the kexec '--noio' option you added
>> to kexec-tools. We still need that fix.
>>
>=20
>=20
>  Does --noio patch works on SN? I remember you have mentioned there is st=
ill some issue when you testing --noio option on SN system?

We need the --noio option to have kexec-kdump working on SN. The problem
was the patch you posted. It was different from the suggestion you
gave me when we first encountered the problem. If we, as you first
suggested, noop all inline function defined in purgatory/arch/ia64/io.h,
then it works.

Is there any issue if the noio patch is changed to your original
suggestion?

Thanks,
 - jay


>=20
>>> However this patch will make Kdump depends on cpu hotplug code, so you =
may
>> add the dependency in Kconfig.
>>
>> I thought Kahalid Aziz's patch covered this?
>> http://lists.osdl.org/mailman/htdig/fastboot/2006-October/004548.html
>>
>=20
>> Thanks,
>>  - jay
>>
>>> Thanks
>>> Zou Nan hai
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

