From: Andrew Morton <akpm@osdl.org>
Date: Mon, 06 Oct 2003 12:34:56 +0000
Subject: Re: current bk goes BUG on ia64 when dumping core
Message-Id: <marc-linux-ia64-106544400328706@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106533868423168@msgid-missing>
In-Reply-To: <marc-linux-ia64-106533868423168@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Roland McGrath <roland@redhat.com> wrote:
>
> > When running the latest LTP code, it dies in the new coredump code.
> 
> This is what I predicted when I sent the second ia64 version of the patch.
> Please refer to that message for complete testing instructions to verify
> the core format is correct (assuming it doesn't crash any more with the new
> patch).  I've made another cosmetic change to avoid using "vsyscall" in
> variable names, and here is that version of the patch relative to the
> current 2.6 tree.

OK, thanks.

Now, Linus is trying to get a good 2.6.0-test7 out the door early this week
and it's not helpful that ia64 goes BUG every time it wants to dump core!

I am in Tokyo and am not able to test your patch.  Could someone please
apply Roland's patch to current -bk, then run Linux Test Project (it BUGged
in two seconds for me) and then send the patch to Linus fairly promptly?

Thanks.

