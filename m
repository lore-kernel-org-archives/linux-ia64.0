From: xb <xavier.bru@bull.net>
Date: Tue, 13 Dec 2005 13:51:54 +0000
Subject: Re: sal record header concern
Message-Id: <439ED1FA.1010702@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------090206000409090005070303"
List-Id: <linux-ia64.vger.kernel.org>
References: <439D4ACE.9020701@bull.net>
In-Reply-To: <439D4ACE.9020701@bull.net>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------090206000409090005070303
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed

Luck, Tony wrote:

>>Is your severity "code" set to 02 80?  VALIDATION_BITS Bit 0 = if 1,
>>the OEM_PLATFORM_ID field below contains valid information.
>>    
>>
>
>If the 16-bit value is 258, then the two bytes must be "02 01" (since
>258 = 2 + 1*256).  This looks perfectly legal ... the "1" in the next
>byte up (the VALIDATION_BITS) indicating that the OEM_PLATFORM_ID
>contains information.
>
>-Tony
>-
>To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>  
>
This is exactly what occurs. Thanks.

--------------090206000409090005070303
Content-Transfer-Encoding: 7bit
Content-Type: text/x-vcard; charset=utf-8;
 name="xavier.bru.vcf"
Content-Disposition: attachment;
 filename="xavier.bru.vcf"

begin:vcard
fn:Xavier Bru
n:Bru;Xavier
adr:;;1 rue de Provence, BP 208;38432 Echirolles Cedex;;;France
email;internet:Xavier.Bru@bull.net
title:BULL/DT/Open Software/linux/ia64
tel;work:+33 (0)4 76 29 77 45
tel;fax:+33 (0)4 76 29 77 70 
x-mozilla-html:TRUE
url:http://www.bull.com
version:2.1
end:vcard


--------------090206000409090005070303--
