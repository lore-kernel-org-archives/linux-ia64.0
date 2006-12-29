From: Grant Grundler <grundler@parisc-linux.org>
Date: Fri, 29 Dec 2006 17:55:16 +0000
Subject: man clone on ia64 incomplete/wrong
Message-Id: <20061229175516.GA32589@colo.lackof.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Helge Deller recently posted a Linux Test Project test failure
on the parisc-linux mailing list:
http://lists.parisc-linux.org/pipermail/parisc-linux/2006-December/031030.html

I took the code snippet he posted and tried to compile/run that
on x86 (no problems) and ia64 (undefined reference to `clone').
This is a "known problem". Email thread from 2003:
http://marc.theaimsgroup.com/?l=linux-ia64&m5778639326638&w=2

The LTP test case was fixed but not the clone man page.
When I was surprised by the link error,  first thing I did was
"man clone" and got the impression there was a bug in ia64 user
space support.  But Helge spared me the digging around and pointed
me at the clone2 code in the original test case.
Anyone working for Intel/HP/Hitachi/SGI/et al care enough to fix
the man page as well?

This would be a good "student" or "intern" task if someone is
looking to contribute to linux without having to know too much.

Basically just need to add a reference to "clone2" and indicate
which architectures do not support clone(2).

thanks,
grant
