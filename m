From: Aron Griffis <aron@hp.com>
Date: Tue, 09 Mar 2004 21:36:06 +0000
Subject: Re: crash on SysRq : Show Memory
Message-Id: <20040309213606.GB26512@mustard.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040309160904.GF7569@mustard.americas.cpqcorp.net>
In-Reply-To: <20040309160904.GF7569@mustard.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kenneth Chen wrote:	[Tue Mar 09 2004, 03:10:50PM EST]
> Looks like it passed beyond show_free_areas(), faulting IP was in the
> while loop accessing mem_map variable.

How did you determine that?

-- 
Aron Griffis
hp Linux and Open Source Lab
Key fingerprint = 4601 AE87 379D A917 BA62  5263 C284 0366 5E6A 3C6B

