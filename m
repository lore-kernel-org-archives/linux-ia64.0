From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Mon, 21 Jun 2004 16:29:46 +0000
Subject: Re: 2.6.7: kallsyms --all-symbols shows a shift in the symbol
Message-Id: <20040621092946.1c762c4d.rddunlap@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <40D70AAC.2010006@bull.net>
In-Reply-To: <40D70AAC.2010006@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 21 Jun 2004 18:19:56 +0200 Xavier Bru wrote:

| Hi all!
| 
| There is a problem with the all kallsyms support in 2.6.7 
| scripts/kallsyms.c.
| Building the table reserves the adresses for all the kernel symbols in 
| first step, then generates the effective addresses of the symbols in step 2.
| The problem is that the symbols used to build the symbol table are not 
| taken in account for the size calculation, but are included in the table 
| in step 2.
| This makes the table "bigger" than was allocated, and the symbols that 
| come behind are shifted.
| This makes kallsyms (and KDB) give wrong addresses for these symbols.
| 
| One solution is to exclude from the symbol table the symbols used for 
| building it (As was provided in KDB patch :-)

Is this the same problem that Keith Owens made a patch for
against 2.6.7-rc3 on 2004-june-15?
Subject: [patch 2.6.7-rc3] When two kallsyms passes are not enough

http://marc.theaimsgroup.com/?l=linux-kernel&m8728234402407&w=2

--
~Randy
