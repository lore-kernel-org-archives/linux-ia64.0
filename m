From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 08 May 2001 03:22:19 +0000
Subject: Re: [Linux-ia64] Linker error : linking constant-gp files with non-constant gp fil es
Message-Id: <marc-linux-ia64-105590693005547@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005546@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005546@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

All objects that are linked into the kernel must be compiled with
-mconstant-gp.  All objects that are linked into modules must not be
compiled with -mconstant-gp.  Set your compile flags accordingly.


