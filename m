From: Jacky Malcles <Jacky.Malcles@bull.net>
Date: Fri, 03 Oct 2003 12:07:39 +0000
Subject: basic questions regarding clone2()
Message-Id: <marc-linux-ia64-106518282910795@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

with ia64, clone2() doesn't set errno to EINVAL when a zero value
is specified for child-stack parameter.
what i'd like to know:
- is clone2() code subject to change shortly?
- what should be expected when child-stack is zeroed
- where can i find a manual page ?
many thanks,

-- 
 Jacky Malcles    	        Email : Jacky.Malcles@bull.net
