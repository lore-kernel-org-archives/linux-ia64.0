From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 06 Nov 2003 12:03:35 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106812072113117@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks, all.

I was pleased to hear many thought in active developer's mind.

I want to check some in MCA recovery.
Here is some steps, roughly say:

 - Stop whole system on MCA even if kernel not suffered.
 - Keep working except the suffered application.
 - Keep working, and give a chance to self-rehabilitation for the suffered
   application.

Just now, Linux is making an effort to step up the second from the first.

It also seems there are some key procedures, such as:

 - Specify process/thread(s) must be killed
 - Specify damaged resources (for example, poisoned pages)

To specify affected ones, OS requires:

 - Physical address (and if possible, Virtual address) of the offending
   operation.
 - Interruption must be synchronized.
 - States in registers when interrupted.

Is it wrong?


------

H.Seto <seto.hidetoshi@jp.fujitsu.com>


