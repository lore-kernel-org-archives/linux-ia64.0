From: Andrew Morton <akpm@osdl.org>
Date: Sat, 21 Aug 2004 21:00:16 +0000
Subject: Re: [PATCH] OProfile ia64 performance counter support
Message-Id: <20040821140016.33900da7.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040821195206.GA10240@compsoc.man.ac.uk>
In-Reply-To: <20040821195206.GA10240@compsoc.man.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Levon <levon@movementarian.org>
Cc: oprofile-list@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@osdl.org

John Levon <levon@movementarian.org> wrote:
>
> This patch provides support for IA64 hardware performance counters via
>  the perfmon interface.

OK - I'll plop this in -mm but I'd ask Tony to do the final merge as and
when it suits the ia64 team.

What's the story on userspace support for oprofile-on-ia64?
