From: Petr Tesarik <ptesarik@suse.cz>
Date: Wed, 12 Dec 2007 14:18:08 +0000
Subject: [PATCH 0/3] ptrace RSE handling - take 2
Message-Id: <475FEDA0.9010104@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch series fixes handling of RSE by ptrace. Second try.

I've incorporated the comments from the last round (with the exception
of a dedicated bit for perfmon).

Again, comments welcome (merging into GIT even more welcome ;),
Petr Tesarik

