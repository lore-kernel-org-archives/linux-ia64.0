From: Andrew Morton <akpm@osdl.org>
Date: Wed, 15 Oct 2003 01:48:07 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106618238410800@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Nathan Scott <nathans@sgi.com> wrote:
>
>  Anyway, here's the two patches (2.6 & 2.4).  The 2.4 version
>  no longer applies cleanly to 2.6 due to other kernel changes,
>  and the 2.6 kernel deprecates one of the 2.4 NFS structures.
> 
>  I'd appreciate any suggestions about a cleaner way to do the
>  common types.h and nfsd/syscall.h header changes.

Can't think of anything clever really.


