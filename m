From: Andreas Schwab <schwab@suse.de>
Date: Mon, 05 Apr 2004 16:56:45 +0000
Subject: Re: Missing include in hugetlbpage.c
Message-Id: <jefzbi748i.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <jesmfi7cdl.fsf@sykes.suse.de>
In-Reply-To: <jesmfi7cdl.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Chen, Kenneth W" <kenneth.w.chen@intel.com> writes:

>>>>> Andreas Schwab wrote on Mon, April 05, 2004 7:01 AM
>>
>> This fixes a missing include file in arch/ia64/mm/hugetlbpage.c in 2.6.5.
>>
>> @@ -9,6 +9,7 @@
>>   */
>>
>>  #include <linux/config.h>
>> +#include <linux/module.h>
>>  #include <linux/init.h>
>>  #include <linux/fs.h>
>>  #include <linux/mm.h>
>
> Just wondering what part depends on that header file, hugetlbpage can't
> be module anyway.

This has nothing to do with being module or not.  EXPORT_SYMBOL also needs
it.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
