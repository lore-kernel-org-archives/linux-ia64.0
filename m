From: Keith Owens <kaos@sgi.com>
Date: Fri, 18 Mar 2005 02:36:58 +0000
Subject: Automatically optimizing hand coded assembler
Message-Id: <7848.1111113418@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The code in ia64_syscall_setup has several independent steps to
execute.  Interleaving the instructions from each step by hand to avoid
empty slots is painful, not to mention error prone.  Are there any
tools available for this task?

I envisage a tool where the user defines the instructions required for
each step separately, including the stop bits needed for ordering
within the individual step.  The resources used by each step must be
disjoint.  The user also defines sync points, where steps must start,
end or join with other steps.  The tool draws the DAG from the sync
points then runs down the DAG, picking instructions from each step to
best fill the slots.  The output is all the instructions, nicely
interleaved to give the minimum number of bundles.

