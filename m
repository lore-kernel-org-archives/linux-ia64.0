From: Francois Wellenreiter <Francois.Wellenreiter@Ext.Bull.Net>
Date: Thu, 27 May 2004 14:57:32 +0000
Subject: Linux 2.6.6 link error when removing -O2 compilation flags
Message-Id: <40B601DC.7090508@Ext.Bull.Net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org




					Hello dear all,


		I was trying to compile my 2.6.6 linux kernel on an IA64 machine
deactivating optimization options (in fact removing "-02" and "-Os" flags
in Makefile and arch/ia64/Makefile).
I've done this test with a gcc-2.96, gcc-3.3.3 and gcc-3.4-20040514
(and removing in this last case "-frename-registers" option).
Has someone else already encountered such a problem ?

