From: Bill Nottingham <notting@redhat.com>
Date: Tue, 26 Jun 2001 17:04:25 +0000
Subject: [Linux-ia64] Re: volatile unsigned long cpu_online_map vs unsigned long cpu_online_map
Message-Id: <marc-linux-ia64-105590693005774@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005772@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005772@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andreas Schwab (schwab@suse.de) said: 
> |> Also, shoudn't it be extern in at least one of setup.c/smpboot.c?
> 
> No.  The definition in setup.c is guarded by CONFIG_SMP, and smpboot.c is
> not use on non-SMP.

But then on a SMP kernel you have two definitions of the same
symbol, yes?

Bill

