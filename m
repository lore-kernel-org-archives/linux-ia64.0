From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 09 Mar 2002 11:08:31 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.5)
Message-Id: <marc-linux-ia64-105590701905243@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 7 Mar 2002 22:38:20 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>OK, I finally got around to take another stab at 2.5.5.  The result
>can be found at ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/
>in file:
>
>	linux-2.5.5-ia64-020307.diff.gz

# bzcat linux-2.5.5-ia64-020307.diff.bz2 | patch -p1 -E --quiet
The next patch would create the file arch/mips/.gdbinit,
which already exists!  Assume -R? [n] 
Apply anyway? [n] 
1 out of 1 hunk ignored -- saving rejects to file arch/mips/.gdbinit.rej

No big deal, the rejected patch is just trying to create exactly the
same contents.


