From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 May 2003 23:31:14 +0000
Subject: Re: [Linux-ia64] kernel 2.5.69 doesn't compile for UP
Message-Id: <marc-linux-ia64-105590723705810@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705787@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705787@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 14 May 2003 20:55:56 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> -	data8 compat_sys_setaffinity
  Andreas> -	data8 compat_sys_getaffinity
  Andreas> +	data8 compat_sys_sched_setaffinity
  Andreas> +	data8 compat_sys_sched_getaffinity

I applied this patch.

Thanks!

	--david

