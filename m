From: Xavier Bru <xavier.bru@bull.net>
Date: Fri, 13 May 2005 17:34:46 +0000
Subject: Re: CONFIG_FORCE_MAX_ZONEORDER default value
Message-Id: <4284E536.3090107@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------000107030004030400070903"
List-Id: <linux-ia64.vger.kernel.org>
References: <200505040850.CAA10967@udlkern.fc.hp.com>
In-Reply-To: <200505040850.CAA10967@udlkern.fc.hp.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------000107030004030400070903
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset="utf-8"; format="flowed"

Hi John & all

We also have a concern about CONFIG_FORCE_MAX_ZONEORDER=18 default value
with 64k page size, we get the message:
"BUG: wrong zone alignment, it will crash"
This is due to the normal zone (4 GB) not being aligned on the maximum 
order boundary (8GB).

A possible fix for this problem is to set the value to 17 for 64k pages...

linux-2.6.11-kgdb/arch/ia64/Kconfig
--- linux-2.6.11r/arch/ia64/Kconfig 2005-05-11 15:23:34.000000000 +0200
+++ linux-2.6.11/arch/ia64/Kconfig 2005-05-13 17:55:56.072557343 +0200
@@ -229,6 +229,7 @@ config IA64_SGI_SN_SIM

config FORCE_MAX_ZONEORDER
int
+ default "17" if IA64_PAGE_SIZE_64KB
default "18"

config SMP

John Marvin wrote:

>I was wondering why CONFIG_FORCE_MAX_ZONEORDER was changed from 19 (in 2.4)
>to 18 (in 2.6). Note that this value sets the maximum number of orders,
>i.e. the actual maximum order is one less, i.e. 17. For the 16Kb default
>page size this gives you a maximum page size of 2Gb, which isn't
>particularly useful on ia64 since that size is not supported. The only
>reason I can see 18 being useful would be to allow for 1Gb huge pages
>on a system where PAGE_SIZE is set to 8Kb.
>
>Anyway, with the default page size being 16K, it seems that it would
>be more appropriate for CONFIG_FORCE_MAX_ZONEORDER to be either 17 (for
>a 1 Gb max huge page size) or 19 (to support the maximum 4 Gb page size
>available on Itanium 2 systems).
>
>Is there another consideration that I've missed?
>
>John Marvin
>-
>To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>  
>


-- 

	Sincères salutations.


--------------000107030004030400070903
Content-Transfer-Encoding: 8bit
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


--------------000107030004030400070903--
