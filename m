From: "John Lee" <jlee@platsolns.com>
Date: Tue, 03 Aug 2004 04:14:10 +0000
Subject: Multiple Processors on OS_MCA
Message-Id: <AEBB9AF2F7713A4FAB1397435451162E7B150F@spock.invent.psi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

MCA experts,

2.6.7 kernel/mca_asm.S serializes processors at the entry and exit of
the OS_MCA with a spinloop, hence makes sure only one processor performs
the OS_MCA at a time.
A processor toggles the spinloop var before exiting OS_MCA so that
another processor spinning on the entry can proceed to OS_MCA.

My question is about the SAL behavior (or OS_MCA behavior) on multiple
processors returnings to SAL after OS_MCA. 
Here's a typical OS_MCA snapshot after global events; the first
processor just returns to SAL w/ IA64_MCA_COLD_BOOT, a second processor
proceeds to OS_MCA, and other processors are still spinning at the
entry.

In this scenario, does SAL just cold boot the system on the first
processor's return, or wait for all processors that were sent to OS_MCA
to return after they all completed OS_MCA? 
If SAL doesn't do the wait, does OS_MCA need to synchronize the
processors on exit so that they all complete OS_MCA in sequence before
returning to SAL?

John
