From: Xavier Bru <xavier.bru@bull.net>
Date: Thu, 21 Oct 2004 14:11:48 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <4177C3A4.8080207@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello Nick & all,

Nick Piggin wrote:

> Luck, Tony wrote:
>
>
>> +    .min_interval        =3D 80,            \
>> +    .max_interval        =3D 320,            \
>> +    .busy_factor        =3D 320,            \
>> +    .imbalance_pct        =3D 125,            \
>> +    .cache_hot_time        =3D (10*1000000),        \
>> +    .balance_interval    =3D 100*(63+num_online_cpus())/64,   \
>>
>> That's a lot of magic numbers and formulae ... are they right?
>> How would a user know if they are right.
>>
>
> To be honest you really wouldn't. It would take a lot of careful
> testing on numerous workloads and systems. I believe SGI is
> starting to do a bit of testing... I don't have the resources to
> do many "real world" tests.
>
> At this stage I wouldn't let them worry you too much :P
> Hopefully they'll gradually improve.

Why should'nt we use the node_distance() function to build in an=20
independant way the Numa hierarchy and compute the right parameters for=20
each level ?


--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________


