From: Andreas Schwab <schwab@suse.de>
Date: Thu, 10 Mar 2005 10:57:08 +0000
Subject: Re: [PATCH] Altix system controller event handling
Message-Id: <je64zzu5tn.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.58.0503090818080.99386@gallifrey.americas.sgi.com>
In-Reply-To: <Pine.SGI.4.58.0503090818080.99386@gallifrey.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Christoph Hellwig <hch@infradead.org> writes:

>> +static unsigned int
>> +scdrv_buffer_to_int(char *buf)
>> +{
>> +	int i;
>> +	unsigned int n =3D 0;
>> +	for( i =3D 0; i < sizeof(n); i++ ) {
>> +		n |=3D ((unsigned)(*(unsigned char *)buf++)
>> +		      << (8 * ((sizeof(n) - i) - 1)));
>
> urgg.  the (*(unsigned char *)buf++) should be just *(buf++), no?
> address arithmetics on signed and unsigned char are the same.

But not value promotion.  The latter gives you a different value when *buf
is negative.  For example if *buf =3D -1 then (unsigned)*buf =3D 0xffffffff,
but (unsigned char)*buf =3D 0xff.

> So
> 	for (i =3D 0; i < sizeof(n); i++)
> 		n |=3D ((unsigned int)buf[i] << (8 * (sizeof(n) - i - 1)));
>
> should do the same, no?

This should be better:

 	for (i =3D 0; i < sizeof(n); i++)
 		n |=3D ((unsigned char)buf[i] << (8 * (sizeof(n) - i - 1)));

Or even better: replace scdrv_buffer_to_int by be32_to_cpup.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
