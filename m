From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 01 Aug 2003 06:34:52 +0000
Subject: Re: [PATCH] New CMC/CPE polling
Message-Id: <marc-linux-ia64-105971970720163@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105969308328993@msgid-missing>
In-Reply-To: <marc-linux-ia64-105969308328993@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


  Alex> +# define SAL_CALL_SAFE(result,args...)

How about calling this SAL_CALL_REENTRANT() or something like that?
SAFE isn't particularly meaningful and it's backwards from the
caller's point of view (where SAL_CALL() is the safe macro to use...).

	--david
