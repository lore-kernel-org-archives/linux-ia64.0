From: "Egan Ford" <egan@sense.net>
Date: Mon, 08 Apr 2002 16:09:53 +0000
Subject: RE: [Linux-ia64] EMP/IPMI and Lion
Message-Id: <marc-linux-ia64-105590701905406@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805842@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805842@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

If all you want is simple power on/off/state/reset with a simple CLU,
then use kimberlite.

You will need to use smConfig, set the port (COM2:) to 19200 and "Always
Active".

http://oss.missioncriticallinux.com/projects/kimberlite/download.php

EMP patch:

http://gort.metaparadigm.com/

>-----Original Message-----
>From: linux-ia64-admin@linuxia64.org 
>[mailto:linux-ia64-admin@linuxia64.org] On Behalf Of Aaron Burt
>Sent: Friday, April 05, 2002 4:36 PM
>To: linux-ia64@linuxia64.org
>Subject: Re: [Linux-ia64] EMP/IPMI and Lion
>
>
>On Tue, 15 Jan 2002, Egan Ford wrote:
>> Has anyone made use of the IPMI/BMC/EMP hardware on the Lion (4-way 
>> SMP) boxes with Linux?  Looking for links, tip, or hints.
>
>Sorry to reply to a stale message, but I just tested VACM's 
>EMP module on our four Lions (2 from HP, 2 from IBM).  Works 
>fine, or at least as well as VACM ever works. 
>http://vacm.sourceforge.net/
>
>You do have to use the smConfig 
>utility to enable the EMP.
>
>If anyone's aware of any other Linux utilities that talk EMP, 
>I'd be very interested.
>
>
>_______________________________________________
>Linux-IA64 mailing list
>Linux-IA64@linuxia64.org 
>http://lists.linuxia64.org/lists/listinfo/linux>-ia64
>


