From: SCHAN@uk.ibm.com
Date: Wed, 17 May 2000 10:40:11 +0000
Subject: [Linux-ia64] IA-32 Support
Message-Id: <marc-linux-ia64-105590678205090@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hello,

We need to get our current IA-32 Linux binary running on our IA64 box - but
when I tried to run it, I got the following error:

ldt_clear: modify_ldt: Function not implemented
ldt_setup: modify_ldt: Function not implemented
Segmentation fault

And on the console it says unexpected IA-32 Exception (Trap 45)

Just wondering is anybody working on implementing those functions yet? I
have looked at the source (2.3.99pre6-0501, from TurboLinux 0501 release)
and there is only stub code in it.

-x-
Sunny Chan
Java Technology Center,
Mail Point 146, IBM UK, Hursley Park, Winchester, England SO21 2JN

Notes ID: Sunny Chan/UK/IBMGB
Email: schan@uk.ibm.com
Telephones: Internal: 246762 External: 01962 816762 Mobile: 07887-704088




