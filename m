From: baswaraj kasture <kbaswaraj@yahoo.com>
Date: Tue, 01 Feb 2005 08:20:01 +0000
Subject: Kernel 2.4.21 hangs up
Message-Id: <20050201082001.43454.qmail@web51102.mail.yahoo.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <41FF0281.6090903@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@muc.de>, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org

Hi,

I compiled kernel 2.4.21 with intel compiler .
While booting it hangs-up . further i found that it
hangsup due to call to "calibrate_delay" routine in
"init/main.c". Also found that loop in the
callibrate_delay" routine goes infinite.When i comment
out the call to "callibrate_delay" routine, it works
fine.Even compiling "init/main.c" with "-O0" works
fine. I am using IA-64 (Intel Itanium 2 ) with EL3.0.

Any pointers will be great help.


Thanks,
-Baswaraj


		
__________________________________ 
Do you Yahoo!? 
Yahoo! Mail - 250MB free storage. Do more. Manage less. 
http://info.mail.yahoo.com/mail_250
