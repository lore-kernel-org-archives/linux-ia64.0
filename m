From: "Faccini, Bruno" <bruno.faccini@intel.com>
Date: Thu, 11 Jan 2001 23:45:47 +0000
Subject: [Linux-ia64] Problem to build Kernel 2.4.0 with gcc version "2.96-ia64-000717"
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C07C28.9EEC5B80"
Message-Id: <marc-linux-ia64-105590693005032@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C07C28.9EEC5B80
Content-Type: text/plain;
	charset="iso-8859-1"


When trying to build Kernel 2.4.0 (from
"http://www.kernel.org/pub/linux/kernel/v2.4/linux-2.4.0.tar.gz" +
"http://www.kernel.org/pub/linux/kernel/ports/ia64//linux-2.4.0-ia64-010109.
diff.gz" downloads) with gcc version "2.96-ia64-000717" + snap "001117" we
experienced compilation errors with the specific
"net/ipv4/netfilter/ip_tables.c" source file.
After some investigations, it appeared to be due to a problem/regression
with version "2.96-ia64-000717" (+ snap "001117" applied, the gcc pkg
shipped as part of RedHat64 "December-2000" Beta release) to deal with the
following macro in "include/linux/netfilter_ipv4/ip_tables.h" header : 
--------------------------------
#define IPT_MATCH_ITERATE(e, fn, args...)	\
({						\
	unsigned int __i;			\
	int __ret = 0;				\
	struct ipt_entry_match *__m;		\
						\
	for (__i = sizeof(struct ipt_entry);	\
	     __i < (e)->target_offset;		\
	     __i += __m->u.match_size) {	\
		__m = (void *)(e) + __i;	\
						\
		__ret = fn(__m , ## args);	\
		if (__ret != 0)			\
			break;			\
	}					\
	__ret;					\
})
--------------------------------
where "## args" substitution was wrongly done (the first argument in the
"...[,...]" list was garbled depending on its first character, "*" or "&"
are missing if specified and if none the full argument/variable name is
fully missing !!, leading to the compiler error because of 2x"," in a row ).
The simplest way to bypass this was to generate a pre-processed only C
source file, to manually edit+fix the problems/missing characters/names and
to use it as the original source file.
This points to some regression between latest gcc versions vs Linux Kernel
source files content and the syntax used (there was a lot of warnings about
"depracated" use of "##" constructs during the Kernel build but the only
error found) and may be highlights the need of a "generic" gcc ship+use for
Kernel builds ...
Bruno.


 <<Bruno Faccini (E-mail).vcf>> 

------_=_NextPart_000_01C07C28.9EEC5B80
Content-Type: application/octet-stream;
	name="Bruno Faccini (E-mail).vcf"
Content-Disposition: attachment;
	filename="Bruno Faccini (E-mail).vcf"

BEGIN:VCARD
VERSION:2.1
N:Faccini;Bruno
FN:Bruno Faccini (E-mail)
ORG:Intel;Technical Marketing/Content Group EMEA
TITLE:Tech. Mktg. Engr.
TEL;WORK;VOICE:+33 (0) 146947228
TEL;WORK;VOICE:+33 (0) 155498427
TEL;WORK;FAX:+33 (0) 146947068
ADR;WORK;ENCODING=QUOTED-PRINTABLE:;Munich, Germany.;Intel Corporation=0D=0ATour Chenonceaux=0D=0A204 Rond Poin=
t Du Pont De Sevres;Boulogne Billancourt;Cedex;92516;France
LABEL;WORK;ENCODING=QUOTED-PRINTABLE:Munich, Germany.=0D=0AIntel Corporation=0D=0ATour Chenonceaux=0D=0A204 Rond =
Point Du Pont De Sevres=0D=0ABoulogne Billancourt, Cedex 92516=0D=0AFrance
ADR;HOME:;;20 Rue Du Marechal Joffre;Brie Comte Robert;;77170;France
LABEL;HOME;ENCODING=QUOTED-PRINTABLE:20 Rue Du Marechal Joffre=0D=0ABrie Comte Robert 77170=0D=0AFrance
EMAIL;PREF;INTERNET:bruno.faccini@intel.com
REV:20001111T162700Z
END:VCARD

------_=_NextPart_000_01C07C28.9EEC5B80--


