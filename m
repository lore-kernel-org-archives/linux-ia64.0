From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 18 Mar 2003 23:00:59 +0000
Subject: Re: [Linux-ia64] Idenitfier clash in read_[un]lock
Message-Id: <marc-linux-ia64-105590723705264@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806152@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806152@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 18 Mar 2003 15:33:42 +0100, Andreas Schwab <schwab@suse.de> said:

  Andreas> The read_lock and read_unlock macros should not use such
  Andreas> innocent variable names like tmp because they have a high
  Andreas> probability to clash with (part of) the argument.

Thanks, I applied this patch for 2.5.  In the future, it would be nice
if you could send patches that apply with "patch -p1" and if you could
specify what kernel the patch is relative to.

	--david

