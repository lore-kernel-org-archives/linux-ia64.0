From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 06 Nov 2002 00:43:54 +0000
Subject: RE: [Linux-ia64] IA64 strncpy in 2.2.4-30 - bug and patch
Message-Id: <marc-linux-ia64-105590709805338@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805337@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805337@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm not able to reproduce the bug with your test case ...

-----Original Message-----
From: Reese Faucette [mailto:reese@myri.com]
Sent: Tuesday, November 05, 2002 4:39 PM
To: bug-glibc@gnu.org; linux-ia64@linuxia64.org
Cc: Akyil, Levent; susan@myri.com
Subject: [Linux-ia64] IA64 strncpy in 2.2.4-30 - bug and patch


Hi,
I opened a bug with RedHat about a problem with strncpy() in glibc-2.2.4-30 on IA64, see https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=76952, but I've been told you folks are really the ones to talk to.
 
The bug report contains a testcase illustrating the problem, and also a patch.  In short, the recovery code is busted, even after the patch from David Mosberger.  Attached is a copy of the patch from the bug report.
 
I have a testcase which exercizes both the recovery3 and recovery4 paths if you're interested.  
Regards,
-reese faucette
 
 


