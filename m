From: Bill Nottingham <notting@redhat.com>
Date: Mon, 07 May 2001 14:27:37 +0000
Subject: [Linux-ia64] debugging threaded apps breaks with current kernel?
Message-Id: <marc-linux-ia64-105590693005538@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When I try to debug threaded apps under 2.4.3 + ia64-010405, I
get segfaults in pthread_handle_create in glibc; if I run the
same program under gdb under 2.4.2 + ia64-010321, it works
fine. Does anyone else see this?

Bill

