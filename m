From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Tue, 14 Jan 2003 19:54:26 +0000
Subject: Re: [Linux-ia64] Problem solved (was: disabling nics in efi.)
Message-Id: <marc-linux-ia64-105590709805672@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805668@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805668@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2003-01-13 at 01:37, Roy Dragseth wrote:
> Hi.
> 
> HP-Support suggested that we tried to disable something called the spanning 
> tree algorithm on the switch.   We did, and voila the problem disappeared.  
> The spanning tre algorithm has a very long timeout, 30 seconds.

AFAIK the 30 seconds timeout is derived from the ISO/IEC 10038 standart.
You can probably lower it on the switch your'e using. 

BTW, note that if you've disabled STP alltogether you lost loop
detection on the LAN. This may or may not be a problem but it's
something to keep in mind.

Hope this helps,
Gilad.



