From: Christian Hinkelbein <hinkelbein@ti.uni-mannheim.de>
Date: Fri, 14 Nov 2003 10:22:23 +0000
Subject: pages already locked on ia64
Message-Id: <marc-linux-ia64-106881037208683@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
i have the need to lock malloc'ed user mem between
kernel calls.

On ia32 i succesfully do a lock_page() on every
page returned by get_user_pages(), lateron i do
unlock_page().
On ia64 sometimes (on ia32 seemingly never) the first
page is already locked, just after malloc().
For a quick hack i check all pages before trying to
lock them, so that i am later just unlocking the
not previously locked ones.

I am quite shure that my approach is totally ill.
Could someone point me to some piece of information that
helps me get cured?

  christian

