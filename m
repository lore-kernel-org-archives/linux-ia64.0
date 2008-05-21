From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 21 May 2008 07:31:10 +0000
Subject: [PATCH 0/2] ia64/pv_ops documentation and pv checker
Message-Id: <12113550722147-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is .S paravirtualization checker and the draft of
the ia64/pv_ops documentation. These patches doesn't change kernel binary.
[PATCH 1/2] ia64/pv_ops: paravirtualized istruction checker.
[PATCH 2/2] ia64/pv_ops: documentation on ia64/pv_ops

The pv checker patch is to show my idea. CPP trick doesn't work because
some instructions includes "."(dot) which CPP doesn't handle well.
So I resorted to use sed in Makefile. Presumably the sed script should
be moved into a separated file.
Although the pv checker doesn't cover all the cases, I expect it can
detect most cases.

thanks,
