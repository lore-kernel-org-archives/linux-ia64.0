From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 14 Sep 2004 14:50:55 +0000
Subject: INIT dumps broken?
Message-Id: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I noticed that with kernel v2.6.9-rc1 INIT dumps appear not to work
anymore.  The machine just hangs, without ever (visibly) control
reaching the OS INIT handler.  v2.6.7-rc3 was OK.  Anybody know what
broke?

	--david
