From: "Faccini, Bruno" <bruno.faccini@intel.com>
Date: Wed, 18 Oct 2000 06:35:46 +0000
Subject: [Linux-ia64] Problems building "2.4.0-test9" kernel source on/for IA-64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C038CD.A59C9F10"
Message-Id: <marc-linux-ia64-105590678205589@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C038CD.A59C9F10
Content-Type: text/plain;
	charset="iso-8859-1"


Hello,

I am posting this just in case it has not been already reported and/or fixed
thru the latest patch versions (ie somewhere between the base "-test9"
source tree version and the current/latest "2.4.0-test10/pre3").
Trying to build "-test9" full tar-ball on/for an IA-64 SDV, I got the
following problems/errors :
	_ multiple compilation errors for "arch/ia64/kernel/setup.c" source
starting with line #215 and apparently related to "definitions/declarations"
issues when it pointed to a routine ("setup_arch()") body !!
In fact this was due to a bug (typo ??) in "setup_arch()" routine itself,
where an "if{}else" statement contained an unnecessary "}" ("} else" at line
#160 in the original "setup.c" source) finally shortening the routine's body
and causing next routines statement to be parsed as
"definitions/declarations".
The following fix/diff corrected the problem :
-------------------------
$ diff setup.c.bfi setup.c.orig
160,165c160
< /*            } else
< This accolade appear to be a "typo" which mainly cause the upper "if"
statemen
t
< and the routine itself to close/end prematurelly, thus causing compilation
< errors for the rest of the routines statements now left outside !!
< B.Faccini (bruno.faccini@intel.com) */
<               else
---
>               } else         
$
-------------------------

	_ "unsatisfied externals" for "[disable,reenable]_usb()" entry
points, in source file "arch/ia64/kernel/irq_ia64.c". This appear to be
caused by a joint setup/configuration of
"CONFIG_ITANIUM_A1_SPECIFIC"+"CONFIG_USB". Since "[disable,reenable]_usb()"
are no longer part of any "-test9" Kernel source, I was only abble to fix
this by not using "CONFIG_ITANIUM_A1_SPECIFIC" setting since this build was
intended for an A3 stepping system, I  assume it should work ...

I did not have already tested this Kernel build, hope it will run/boot ok,
and I will post any further issue.

Bruno.

> Bruno Faccini - Tech. Mktg. Engr.
> Technical Marketing/Internet Solutions Group (EMEA)
> Intel GmbH, Germany
> Phone (Intel office): +33-(0)146947228
>       Fax: +33-(0)146947068
>       email: bruno.faccini@intel.com
> 
 <<Bruno Faccini (E-mail).vcf>> 

------_=_NextPart_000_01C038CD.A59C9F10
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

------_=_NextPart_000_01C038CD.A59C9F10--


