From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 16 Aug 2005 23:04:24 +0000
Subject: Re: [PATCH] Fix gcc 4 warnings on ia64
Message-Id: <17154.28920.424898.297805@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050816155747.GN20749@wotan.suse.de>
In-Reply-To: <20050816155747.GN20749@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Andi" = Andi Kleen <ak@suse.de> writes:

Andi> I was compiling an IA64 2.6.13rc6 kernel on a machine with gcc 4
Andi> to test something. The compile spew a incredibly large number of
Andi> warnings. This patch fixes the most annoying ones from commonly
Andi> included makefiles. In these two cases gcc was complaining that
Andi> functions cannot be volatile or const.

You actually need the const attribute on __ia64_get_io_port_base ---
see the thread at
http://www.gelato.unsw.edu.au/archives/linux-ia64/0507/14658.html 

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
