From: Christian Cotte-Barrot <Christian.Cotte-Barrot@bull.net>
Date: Thu, 14 Nov 2002 09:01:44 +0000
Subject: [Linux-ia64] Re: memcpy failure
Message-Id: <marc-linux-ia64-105590709805424@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Chen, Kenneth W" wrote:
> 
> The retrun value for memcpy doesn't follow the user space memcpy exactly.
> kernel memcpy always return 0.
> - Ken
> 

But memcpy from memcpy.S is returning a pointer to dest area.
That would lead to quasi non-portable code when the return from memcopy
is correctly checked depending on which memcopy function is addressed.
But BTW, is it meaningful to take into account a return code
that is always the same and which value is known in advance ?
Does memcpy suppose to failed in some cases ?

