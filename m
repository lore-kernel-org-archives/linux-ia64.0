From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 09 May 2001 11:45:26 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.4)
Message-Id: <marc-linux-ia64-105590693005556@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 8 May 2001 22:07:41 -0700, 
David Mosberger <davidm@hpl.hp.com> wrote:
>The latest IA-64 patch is (finally) available at:
>
> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/
>
>in file linux-2.4.4-ia64-010508.diff*.

There were two versions of linux-2.4.4-ia64-010508.diff.bz2 on
ports/ia64, about 45 minutes apart.  The kdb patch was against the
first version of ia64-010508 and gets a compile error on E1_PAUSE.  I
have uploaded a new copy of kdb-v1.8-2.4.4-ia64-010508.gz to
oss.sgi.com, this one is timestamped May 9 11:37 UTC and is against the
copy of ia64-010508 with timestamp May 9 04:51 UTC.


