From: Xavier Bru <xavier.bru@bull.net>
Date: Wed, 17 Dec 2003 08:06:12 +0000
Subject: Re: [PATCH] initialize bootmem maps in reverse order
Message-Id: <marc-linux-ia64-107164836708219@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107151544512148@msgid-missing>
In-Reply-To: <marc-linux-ia64-107151544512148@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Jesse Barnes a =E9crit :

>On Mon, Dec 01, 2003 at 11:25:20AM -0800, Jesse Barnes wrote:
> =20
>
>>On Mon, Dec 01, 2003 at 09:22:12AM -0800, Jesse Barnes wrote:
>>   =20
>>
>>>Yeah, sorry about that, I knew there would be a problem.  We need to fix
>>>the ia64 discontig code to init the boot memory in the correct order
>>>instead since the below change breaks other discontig platforms.
>>>     =20
>>>
>>It looks like we should break out the second half of
>>discontig.c:find_pernode_space() into a second function that inits the
>>bootmaps in reverse order.  As an added bonus, we could check to make
>>sure that all of the pernode spaces actually got allocated and print a
>>warning and/or disable the node if not.  That would make debugging weird
>>init time failures a bit easier (I think Alex ran into a problem that
>>would have been quickly solved if we had such checks).  Wanna take a
>>stab at it?
>>   =20
>>
>
>Does this patch work for you?  It does a few things:
>
>  o simplifies discontig.c:find_pernode_space() a bit due to the below
>    points
>  o does a sanity check to make sure that pernode spaces were
>    successfully allocated
>  o initializes the bootmem maps in reverse order
>
>If it looks ok, we can queue it up for 2.6.1.
>
>Jesse
>
> =20
>
hello Jesse

The patch works OK for us.
Thanks !
Xavier

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________


