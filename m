From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 21 May 2001 02:03:50 +0000
Subject: Re: [Linux-ia64] Buggy unwind tables in user space
Message-Id: <marc-linux-ia64-105590693005629@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005627@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005627@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 19 May 2001 13:45:27 +1000, 
Keith Owens <kaos@ocs.com.au> wrote:
>Most IA64 distributions contain a bad version of crtn.o.  Executables
>or shared libraries built with this file have invalid unwind data.
>
>SuSe Linux 7.1a, TurboLinux 000828, TL 010307 (beta3) and Redhat 7.0.90
>all have a buggy version of crtn.o.  Redhat 7.0.98 (Wolverine) has a
>clean version of crtn.o, but if any Wolverine binaries were compiled
>against the old crtn.o then they will be bad as well.

Correction.  Redhat 7.0.98 (Wolverine) also has a buggy version of
crtn.o.


