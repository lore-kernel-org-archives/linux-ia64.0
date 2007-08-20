From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 20 Aug 2007 16:11:28 +0000
Subject: perfmon2 kernel: git tree up and running
Message-Id: <20070820161128.GB10272@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070820131605.GE8667@frankl.hpl.hp.com>
In-Reply-To: <20070820131605.GE8667@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, rientjes@google.com, akpm@linux-foundation.org, ak@suse.de

Hello,

I am happy to announce that we now have a GIT tree for the perfmon2
kernel. This way you will all be able to track closely the latest
perfmon2 changes. We will also be able to better track the main
kernel changes.

You can get your copy of the tree by doing:

        git clone git://git.kernel.org/pub/scm/linux/kernel/git/eranian/linux-2.6

As of today, you have 2.6.23-rc3 + the latest perfmon changes from 2.6.22.

The tree also includes modifications to the Intel Core processors support
to allow more than one counter to be used when PEBS is active.

Enjoy,

--
-Stephane
