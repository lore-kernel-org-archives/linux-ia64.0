From: Keith Owens <kaos@sgi.com>
Date: Tue, 13 Dec 2005 04:11:21 +0000
Subject: Re: sal record header concern
Message-Id: <6640.1134447081@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <439D4ACE.9020701@bull.net>
In-Reply-To: <439D4ACE.9020701@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 12 Dec 2005 11:02:54 +0100, 
xb <xavier.bru@bull.net> wrote:
>This is a multi-part message in MIME format.
>--------------040306040709010208040006
>Content-Transfer-Encoding: 7bit
>Content-Type: text/plain; charset=ISO-8859-1; format=flowed

Please change your mailer not to use format=flowed.  It destroys the
patch format.

>It seems there is a concern around the SAL record header:
>     SEVERITY item is defined as a 8 bits item in SAL documentation 
>($B.2.1 rev december 2003), but as an u16 in sal.h.
>This has the side effect that current code in mca.c does not call 
>ia64_sal_clear_state_info() upon receiving corrected platform errors 
>(priority is reported as 258 instead of 2).

I agree that the record definition is wrong, it should be a pair of
bytes.  However I want to check why you are seeing a value of 258
instead of 2.  hd output on a typical SGI salinfo record header

0000  03 00 00 03  F4 A1 02 00  02 00 02 00  38 02 00 00  * ............8... *
      |-------- ID ----------|  |rev| |sev|  |--length-|

Even though the severity code is defined as 2 bytes instead of the
correct 1 byte, it still gives the value '2' in little endian mode.

Is your severity "code" set to 02 80?  VALIDATION_BITS Bit 0 = if 1,
the OEM_PLATFORM_ID field below contains valid information.

Useful command 'hd', defined as

hexdump  -e '"%04.4_Ax\n"' \
         -e '"%04.4_ax  "' \
         -e '4/1 "%02X " "  " 4/1 "%02X " "  " 4/1 "%02X " "  " 4/1 "%02X "' \
         -e '"  * " 16/1 "%_p" " *"' \
         -e '"\n"' \
         $*

