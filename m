From: Josue Amaro <josue.amaro@oracle.com>
Date: Tue, 10 Apr 2001 05:05:46 +0000
Subject: [Linux-ia64] 32 bit compatibility on IA-64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------115DD8AEDD7C45F82D829383"
Message-Id: <marc-linux-ia64-105590693005385@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------115DD8AEDD7C45F82D829383
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

All,

While testing IA-32 compatibility on IA-64 I ran into this problem:

 Initializing Java
 Virtual Machine from
../stage/Components/oracle.swd.jre/1.1.8/1/DataFiles/Expanded/linux/bin/jre.

Please wait...
ldt_clear: modify_ldt: Function not implemented
ldt_setup: modify_ldt: Function not implemented

At this point the JRE stops working and exits.

The Oracle installer runs on IBM's 1.1.8 JRE for Linux (32).

Regards,
--
"When you see the correct course, act; do not wait for orders."
The Art of War

=======================================================================
  Josue Emmanuel Amaro                         Josue.Amaro@oracle.com
  Linux Products Manager                       Phone:   650.506.1239
  Intel and Linux Technologies Group           Fax:     650.413.0167
=======================================================================


--------------115DD8AEDD7C45F82D829383
Content-Type: text/x-vcard; charset=UTF-8;
 name="josue.amaro.vcf"
Content-Transfer-Encoding: 7bit
Content-Description: Card for Josue Amaro
Content-Disposition: attachment;
 filename="josue.amaro.vcf"

begin:vcard 
n:Amaro;Josue
tel;fax:650 413 0167
tel;work:650 506 1239
x-mozilla-html:FALSE
url:www.oracle.com
org:Oracle Corporation
version:2.1
email;internet:josue.amaro@oracle.com
title:Linux Products Manager
adr;quoted-printable:;;500 Oracle Parkway=0D=0AMS 401 ip 4;Redwood Shores;CA;94065;United States
fn:Josue Amaro
end:vcard

--------------115DD8AEDD7C45F82D829383--


