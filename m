From: Matthew Wilcox <willy@debian.org>
Date: Mon, 17 Nov 2003 17:30:53 +0000
Subject: Re: [PATCH] - prof_cpu_mask problems
Message-Id: <marc-linux-ia64-106909030600564@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106901123527791@msgid-missing>
In-Reply-To: <marc-linux-ia64-106901123527791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 17, 2003 at 09:16:01AM -0800, Luck, Tony wrote:
> Although it's ugly ... that format seems to have been adopted in
> generic code ... here's the code from drivers/base/node.c to
> display the bitmap of cpus that belong to a node:

William Irwin has a patch to fix this case.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
