From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Thu, 11 Jul 2002 16:29:57 +0000
Subject: [Linux-ia64] RE: kernel update (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905765@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205855@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205855@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen
I installed your patch and could run the ltp suite without any oops or
sytem hang. 
Thanks !
Xavier 

Chen, Kenneth W writes:
 > This patch fixes some critical bugs in copy_user exception handler found by
 > Xavier.  The fixes are all in the exception handler and there are no changes
 > in the main "copy" body.  I have tested with both gcc2.96 and gcc3.1
 > compiler.  Please report issues to me if there are any.  Thanks.
 > 
 > - Ken
 > 

