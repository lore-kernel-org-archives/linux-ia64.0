From: Keith Owens <kaos@sgi.com>
Date: Wed, 14 May 2003 02:06:33 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.21-rc1 Close rmmod race on ia64
Message-Id: <marc-linux-ia64-105590723705768@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705748@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705748@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 13 May 2003 12:52:36 +0200, 
Andreas Schwab <schwab@suse.de> wrote:
>Keith Owens <kaos@sgi.com> writes:
>
>|> @@ -51,10 +53,11 @@ search_exception_table (unsigned long ad
>|>  		fix.cont = entry->cont + main_gp;
>|>  	return fix;
>|>  #else
>|> -	struct archdata *archdata;
>
>??? archdata is still needed.

I did the original patch against 2.4.20 which does not have archdata
then I made an error on the merge up to 2.4.21-rc1.  -ENOTENOUGHSLEEP.


