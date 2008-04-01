From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Tue, 01 Apr 2008 10:38:31 +0000
Subject: [Patch][00/18] kvm-ia64 for kernel V9
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC0104871F@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, All
According to the comments from V8, I refined the code, and worked out
the new patchset. Please help to review. Thanks! :-)
In this new version, most of typdefs are removed to comply with the
requirement of coding style. Fixed the issues found by reviewers. Thanks
for your effort! 
 The whole patchset are checked by the script checkpatch.pl. Except that
one file including asmbly code will report some warnings, the other one
should be good to check-in. 
Xiantao
