From: chas williams <chas@cmf.nrl.navy.mil>
Date: Tue, 03 Jul 2001 21:04:29 +0000
Subject: Re: [Linux-ia64] patching sys_call_table from a module
Message-Id: <marc-linux-ia64-105590693005813@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005808@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005808@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>`-mconstant-gp' which I didn't see in your flags list.  In general,
>you must compile your modules with the same flags that were

that's a problem.  modules cant be compiled with -mconstant-gp apparently.

