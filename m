From: "Raj Patil" <rpatil0299@hotmail.com>
Date: Mon, 12 Apr 2004 20:03:15 +0000
Subject: newbie question regarding alloc instruction
Message-Id: <BAY14-F14u04koK5uA700042e41@hotmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hello,

I have a basic question about alloc instruction. I apologise if it  is too 
basic. BUt,
I could not find the info in the docs I looked at...

Are there any restrictions in using alloc  instruction more than once in a 
function?
(I see that some of the kernel functions do use more than once)
If not, do I need to worry about setting/unsetting the CFM etc or will it be
taken care by setting/resetting ar.pfs in the block.  (According to one of 
the
manuals CFM can not bet set manually.)

Thanks for any pointers/info.

Regards,
Raj

_________________________________________________________________
Check out MSN PC Safety & Security to help ensure your PC is protected and 
safe. http://specials.msn.com/msn/security.asp

