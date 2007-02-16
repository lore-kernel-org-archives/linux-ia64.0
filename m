From: Andreas Schwab <schwab@suse.de>
Date: Fri, 16 Feb 2007 15:13:55 +0000
Subject: Re: [KJ] [PATCH] is_power_of_2 in ia64mm
Message-Id: <jeire2nnik.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1171627435.6127.0.camel@wriver-t81fb058.linuxcoe>
	<45D5C789.1090607@student.ltu.se>
In-Reply-To: <45D5C789.1090607@student.ltu.se> (Richard Knutsson's message of
	"Fri, 16 Feb 2007 16:02:33 +0100")
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Richard Knutsson <ricknu-0@student.ltu.se>
Cc: Vignesh Babu BM <vignesh.babu@wipro.com>, Kernel Janitors List <kernel-janitors@lists.osdl.org>, linux-mm@kvack.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Richard Knutsson <ricknu-0@student.ltu.se> writes:

> Vignesh Babu BM wrote:
>> @@ -175,7 +176,7 @@ static int __init hugetlb_setup_sz(char *str)
>>  		tr_pages =3D 0x15557000UL;
>>   	size =3D memparse(str, &str);
>> -	if (*str || (size & (size-1)) || !(tr_pages & size) ||
>> +	if (*str || !is_power_of_2(size) || !(tr_pages & size) ||
>>  		size <=3D PAGE_SIZE ||
>>  		size >=3D (1UL << PAGE_SHIFT << MAX_ORDER)) {
>>  		printk(KERN_WARNING "Invalid huge page size specified\n");
>>
>>  =20
> As we talked about before; is this really correct? !is_power_of_2(0) =3D
> true while (0 & (0-1)) =3D 0.

size =3D 0 is also covered by the next two conditions, so the overall value
does not change.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
