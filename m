From: Andrew Morton <akpm@osdl.org>
Date: Wed, 15 Oct 2003 05:18:10 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106619493718525@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> wrote:
>
> NFS is nastier (ugly multiplexed syscalls...). 

Well I think that whole interface is deprecated anyway and the new nfsutils
doesn't use it - it uses exportfs instead.

You'd need to check with Neil, but if I'm right you could just say "use
current nfsutils on ia64".


