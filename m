From: "Faccini, Bruno" <bruno.faccini@intel.com>
Date: Sat, 04 Nov 2000 10:53:01 +0000
Subject: [Linux-ia64] Kernel build from last "linux-2_4_0-test9-ia64-001030_diff.gz" cr
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C0464D.6690B6C0"
Message-Id: <marc-linux-ia64-105590678205655@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C0464D.6690B6C0
Content-Type: text/plain;
	charset="iso-8859-1"


Tried to build a Linux Kernel after applying last
"linux-2_4_0-test9-ia64-001030_diff.gz" patch, but it failed/crashed solid
at boot time with the following msgs/symptoms :

-----------------------
...

init.c:80: bad pgd 4000210018806000
Kernel Panic: Out of memory.
In idle task - not syncing.

...

----------------------

Both "-test9" with earlier patch (ie,
"linux-2.4.0-test9-ia64-001004.diff.gz") and "-test10" kernel builded with
the same configuration run fine.

Seems that there are some issues + lack of testing with this last "-test9"
patch.

The target platform is a BigSur IA-64 SDV uni-processor (A2 Stepping) with
only 1Gbytes memory.

Bruno.

> Bruno Faccini - Tech. Mktg. Engr.
> Technical Marketing/Internet Solutions Group (EMEA)
> Intel GmbH, Germany
> Phone (Intel office): +33-(0)146947228
>       Fax: +33-(0)146947068
>       email: bruno.faccini@intel.com
> 
 <<Bruno Faccini (E-mail).vcf>> 

------_=_NextPart_000_01C0464D.6690B6C0
Content-Type: application/octet-stream;
	name="Bruno Faccini (E-mail).vcf"
Content-Disposition: attachment;
	filename="Bruno Faccini (E-mail).vcf"

BEGIN:VCARD
VERSION:2.1
N:Faccini;Bruno;;;
FN:Bruno Faccini
ORG:Intel;Technical Marketing/Content Group EMEA
TITLE:Tech. Mktg. Engr.
TEL;WORK;VOICE:+33 (0) 146947228
TEL;WORK;VOICE:+33 (0) 155498427
TEL;HOME;VOICE:
TEL;CELL;VOICE:
TEL;WORK;FAX:+33 (0) 146947068
ADR;WORK;ENCODING=QUOTED-PRINTABLE:;Munich, Germany.;Intel Corporation=0D=0ATour Chenonceaux=0D=0A204 Rond Poin=
t Du Pont De Sevres;Boulogne Billancourt;Cedex;92516;France
LABEL;WORK;ENCODING=QUOTED-PRINTABLE:Munich, Germany.=0D=0AIntel Corporation=0D=0ATour Chenonceaux=0D=0A204 Rond =
Point Du Pont De Sevres=0D=0ABoulogne Billancourt, Cedex 92516=0D=0AFrance
ADR;HOME:;;20 Rue Du Marechal Joffre;Brie Comte Robert;;77170;France
LABEL;HOME;ENCODING=QUOTED-PRINTABLE:20 Rue Du Marechal Joffre=0D=0ABrie Comte Robert 77170=0D=0AFrance
EMAIL;PREF;INTERNET:bruno.faccini@intel.com
REV:20000527T141533Z
END:VCARD

------_=_NextPart_000_01C0464D.6690B6C0--


