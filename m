From: Xavier Bru <xavier.bru@bull.net>
Date: Thu, 17 Feb 2005 11:05:00 +0000
Subject: Re: Allow to change SD_NODES_PER_DOMAIN at configuration or boot
Message-Id: <42147A5C.30007@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050708080604060803070600"
List-Id: <linux-ia64.vger.kernel.org>
References: <42138013.3060909@bull.net>
In-Reply-To: <42138013.3060909@bull.net>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------050708080604060803070600
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"; format="flowed"

Nick Piggin wrote:

>Right. It may make more sense to have the setup based on some
>maximum distance between nodes. Eg. all nodes less than distance
>10 away from node0 are to be in node0's first level NUMA domain
>(the next level is always global, IIRC).
>
>Then you would still need some configuration option, but it would
>appear to be a more useful metric to use.
>
> =20
>
Hello Nick & all,
Do you mean that there should ever be only one NUMA sched-domain level ?
On a 2x4x4 cpus machine, we could in theory have  SD_NODES_PER_DOMAIN=3D4, =

thus providing a 2 level NUMA sched-domain (domain 0 spans 4 cpus,=20
domain 1 spans 16, domain 2 is global and spans 32).
But it is true that this configuration does not show evident performance=20
gains upon SD_NODES_PER_DOMAIN=3D8 (domain 0 spans 4 cpus, domain 1 is=20
global and spans 32), at least on parallel compilation of the kernel.
Providing SD_NODES_PER_DOMAIN as a boot parameter was also intended to=20
choose between a multilevel sched-domains or not.

--=20

	Sinc=E8res salutations.


--------------050708080604060803070600
Content-Transfer-Encoding: 7bit
Content-Type: text/x-vcard; charset=utf-8;
 name="xavier.bru.vcf"
Content-Disposition: attachment;
 filename="xavier.bru.vcf"

begin:vcard
fn:Xavier Bru
n:Bru;Xavier
adr:;;1 rue de Provence, BP 208;Echirolles;;38432 Cedex;France
email;internet:Xavier.Bru@bull.net
title:BULL/DT/Open Software/linux/ia64
tel;work:+33 (0)4 76 29 77 45
tel;fax:+33 (0)4 76 29 77 70
x-mozilla-html:TRUE
url:http://www-frec.bull.fr
version:2.1
end:vcard


--------------050708080604060803070600--
