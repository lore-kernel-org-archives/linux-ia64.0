From: Ulrich Drepper <drepper@redhat.com>
Date: Thu, 15 May 2003 00:26:45 +0000
Subject: Re: [Linux-ia64] libc umount and umount2 can't both be right
Message-Id: <marc-linux-ia64-105590723705813@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705762@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705762@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andreas Schwab wrote:

> [ SYS_umount is actually umount2 on ia64 ]

Indeed.  This is the right patch, I've applied it.  Thanks,

- -- 
- --------------.                        ,-.            444 Castro Street
Ulrich Drepper \    ,-----------------'   \ Mountain View, CA 94041 USA
Red Hat         `--' drepper at redhat.com `---------------------------
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE+wt7F2ijCOnn/RHQRAk3CAKCtCGqcjD3nhWuJenbeKKfWRWnHFACfdT/D
XdI87pwOvJw8IdGtnhQ0mhY=M4/U
-----END PGP SIGNATURE-----


